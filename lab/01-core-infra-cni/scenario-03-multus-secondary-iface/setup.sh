#!/usr/bin/env bash
set -euo pipefail
NS=net-lab3
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

# --- Infrastructure plumbing (not the lesson itself) ---
# Cilium runs in "exclusive CNI" mode by default: it actively watches
# /etc/cni/net.d and renames any other CNI's config file to "*.cilium_bak"
# so it stays the sole active CNI. That's exactly what would silently
# neutralize Multus here. Disable it so Multus can actually take over as the
# meta-plugin.
if [ "$(kubectl -n kube-system get cm cilium-config -o jsonpath='{.data.cni-exclusive}' 2>/dev/null)" != "false" ]; then
  echo "Disabling Cilium's CNI exclusivity so Multus can coexist..."
  helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
    --set standaloneDnsProxy.enabled=false \
    --set cni.exclusive=false >/dev/null
  kubectl -n kube-system rollout restart daemonset/cilium
  kubectl -n kube-system rollout status daemonset/cilium --timeout=120s
fi

# Most kind node images only ship the CNI binaries Cilium itself needs
# (cilium-cni, host-local, loopback, portmap, ptp) — not the full standard
# CNI plugins bundle. The "bridge" plugin our NetworkAttachmentDefinition
# uses isn't there by default, so the secondary interface would silently
# fail to attach. Install the missing binaries on every node if needed.
CNI_VERSION=$(curl -fsSL https://api.github.com/repos/containernetworking/plugins/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
for NODE in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  if ! docker exec "$NODE" test -f /opt/cni/bin/bridge 2>/dev/null; then
    echo "Installing the 'bridge' CNI plugin binary on $NODE..."
    curl -fsSL -o /tmp/ckne-cni-plugins.tgz \
      "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz"
    docker cp /tmp/ckne-cni-plugins.tgz "$NODE:/root/ckne-cni-plugins.tgz"
    docker exec "$NODE" tar xzf /root/ckne-cni-plugins.tgz -C /opt/cni/bin ./bridge ./macvlan
    docker exec "$NODE" rm -f /root/ckne-cni-plugins.tgz
  fi
done
rm -f /tmp/ckne-cni-plugins.tgz

echo "Installing Multus CNI (official thick plugin manifest)..."
kubectl apply -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset.yml
kubectl -n kube-system rollout restart daemonset/kube-multus-ds
kubectl -n kube-system rollout status daemonset/kube-multus-ds --timeout=120s

# Even with cni.exclusive=false, Multus's own init container has been
# observed writing its generated config as "00-multus.conf.cilium_bak"
# instead of the active "00-multus.conf" on this environment — copy it to
# the name kubelet actually picks up on every node.
sleep 5
for NODE in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  if docker exec "$NODE" test -f /etc/cni/net.d/00-multus.conf.cilium_bak 2>/dev/null && \
     ! docker exec "$NODE" test -f /etc/cni/net.d/00-multus.conf 2>/dev/null; then
    echo "Activating Multus's CNI config on $NODE..."
    docker exec "$NODE" cp /etc/cni/net.d/00-multus.conf.cilium_bak /etc/cni/net.d/00-multus.conf
  fi
done

echo "Multus installed and active. Now create in the '$NS' namespace:"
echo "  1) a NetworkAttachmentDefinition (type bridge)"
echo "  2) a pod with the k8s.v1.cni.cncf.io/networks annotation pointing at that NAD"
