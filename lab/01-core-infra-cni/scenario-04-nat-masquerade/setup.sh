#!/usr/bin/env bash
set -euo pipefail
NS=net-lab4
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: client, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: client}}
  template:
    metadata: {labels: {app: client}}
    spec:
      containers:
      - name: client
        image: nicolaka/netshoot
        command: ["sleep", "infinity"]
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=client --timeout=90s

NODE=$(kubectl -n "$NS" get pod -l app=client -o jsonpath='{.items[0].spec.nodeName}')
echo "Client pod scheduled on $NODE."

# Break something real: remove the MASQUERADE rule inside Cilium's own
# CILIUM_POST_nat chain (this is where Cilium actually puts it — NOT
# necessarily matching the Node.spec.podCIDR that kubeadm/kind allocated,
# since Cilium's default cluster-pool IPAM assigns its own range).
LINE=$(docker exec "$NODE" iptables -t nat -L CILIUM_POST_nat -n --line-numbers 2>/dev/null | awk '/MASQUERADE/{print $1; exit}')
if [ -z "$LINE" ]; then
  echo "Couldn't find a MASQUERADE rule in CILIUM_POST_nat on $NODE — is Cilium using BPF masquerading instead of iptables? Check 'cilium status | grep Masquerading'." >&2
  exit 1
fi
echo "Removing MASQUERADE rule (line $LINE of CILIUM_POST_nat) on $NODE (simulating the 'cleanup')..."
docker exec "$NODE" iptables -t nat -D CILIUM_POST_nat "$LINE"

echo "Namespace: $NS ready. Outbound internet traffic from $NODE should now fail."
