#!/usr/bin/env bash
set -euo pipefail

NS=net-lab1
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

WORKER1=$(kubectl get nodes -o jsonpath='{.items[?(@.metadata.labels.kubernetes\.io/hostname=="ckne-worker")].metadata.name}')
WORKER2=$(kubectl get nodes -o jsonpath='{.items[?(@.metadata.labels.kubernetes\.io/hostname=="ckne-worker2")].metadata.name}')
[ -z "$WORKER1" ] && WORKER1="ckne-worker"
[ -z "$WORKER2" ] && WORKER2="ckne-worker2"

cat <<EOF | kubectl apply -f -
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
EOF

echo "Esperando a que los pods estén Running..."
kubectl -n "$NS" wait --for=condition=Ready pod -l app=web-a --timeout=90s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=web-b --timeout=90s

# --- Rompemos algo real a nivel de nodo (docker exec al namespace de red del nodo) ---
POD_CIDR_WORKER1=$(kubectl get node "$WORKER1" -o jsonpath='{.spec.podCIDR}')
echo "$POD_CIDR_WORKER1" > /tmp/ckne-broken-route.txt

echo "Eliminando en $WORKER2 la ruta hacia $POD_CIDR_WORKER1 (simulando el error humano)..."
docker exec "$WORKER2" sh -c "ip route del $POD_CIDR_WORKER1 2>/dev/null || true"

echo "Listo. web-b (en $WORKER2) ya NO puede alcanzar pods en $WORKER1 ($POD_CIDR_WORKER1)."
echo "Namespace: $NS"
