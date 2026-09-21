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

# Break something real: block forwarded HTTPS traffic from this node's pod
# subnet in the FORWARD chain, simulating an overly broad firewall rule
# someone added. Using FORWARD (not OUTPUT/POSTROUTING) keeps this
# independent of whether Cilium's masquerading happens to be iptables-based
# or BPF-based on this cluster — either way, forwarded pod traffic still
# passes through FORWARD before any NAT/masquerade decision.
POD_CIDR=$(kubectl get ciliumnode "$NODE" -o jsonpath='{.spec.ipam.podCIDRs[0]}')
if [ -z "$POD_CIDR" ]; then
  echo "Couldn't read CiliumNode.spec.ipam.podCIDRs for $NODE." >&2
  exit 1
fi
echo "Blocking forwarded HTTPS traffic from $POD_CIDR on $NODE (simulating an overly broad firewall rule)..."
docker exec "$NODE" iptables -I FORWARD -s "$POD_CIDR" -p tcp --dport 443 -j DROP

echo "Namespace: $NS ready. Outbound HTTPS traffic from pods on $NODE should now fail."
