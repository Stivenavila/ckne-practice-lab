#!/usr/bin/env bash
set -euo pipefail

NS=net-lab1
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

WORKER1=$(kubectl get nodes -o jsonpath='{.items[?(@.metadata.labels.kubernetes\.io/hostname=="ckne-worker")].metadata.name}')
WORKER2=$(kubectl get nodes -o jsonpath='{.items[?(@.metadata.labels.kubernetes\.io/hostname=="ckne-worker2")].metadata.name}')
[ -z "$WORKER1" ] && WORKER1="ckne-worker"
[ -z "$WORKER2" ] && WORKER2="ckne-worker2"

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: web-a, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: web-a}}
  template:
    metadata: {labels: {app: web-a}}
    spec:
      nodeSelector: {kubernetes.io/hostname: $WORKER1}
      containers:
      - name: web-a
        image: nicolaka/netshoot
        command: ["sleep", "infinity"]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: web-b, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: web-b}}
  template:
    metadata: {labels: {app: web-b}}
    spec:
      nodeSelector: {kubernetes.io/hostname: $WORKER2}
      containers:
      - name: web-b
        image: nicolaka/netshoot
        command: ["sleep", "infinity"]
YAML

echo "Waiting for pods to be Running..."
kubectl -n "$NS" wait --for=condition=Ready pod -l app=web-a --timeout=90s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=web-b --timeout=90s

# --- Break something real at the node level: block Cilium's VXLAN overlay
# port (8472/udp) between the two worker nodes, simulating an overly broad
# firewall rule. This is deliberately NOT "delete an ip route" — with
# Cilium's default tunnel/vxlan routing mode, cross-node pod traffic is
# encapsulated and forwarded via eBPF, so host routing-table entries for the
# remote pod CIDR aren't actually consulted for the forwarding decision.
# Blocking the real transport (the VXLAN UDP port) is what actually breaks
# connectivity here.
WORKER1_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$WORKER1")
echo "$WORKER1_IP" > /tmp/ckne-blocked-peer.txt

echo "Blocking VXLAN (udp/8472) from $WORKER1 ($WORKER1_IP) on $WORKER2 (simulating an overly broad firewall rule)..."
docker exec "$WORKER2" iptables -A INPUT -p udp --dport 8472 -s "$WORKER1_IP" -j DROP

echo "Done. web-b (on $WORKER2) can NO LONGER reach pods on $WORKER1."
echo "Namespace: $NS"
