#!/usr/bin/env bash
set -euo pipefail
NS=net-lab2
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

WORKER2=$(kubectl get nodes -o name | grep worker2 | sed 's#node/##') || true
[ -z "${WORKER2:-}" ] && WORKER2="ckne-worker2"

# Force everything onto a single node by requesting lots of CPU per replica,
# so the node runs out of allocatable capacity (a real Pending, a real cause).
# The per-pod request is computed from the node's ACTUAL allocatable CPU
# (not a fixed "300m") so this reliably oversubscribes regardless of how
# beefy the machine running this lab is — a fixed value only broke on small
# VMs and silently did nothing on larger ones.
ALLOCATABLE_CPU=$(kubectl get node "$WORKER2" -o jsonpath='{.status.allocatable.cpu}')
if [[ "$ALLOCATABLE_CPU" == *m ]]; then
  ALLOCATABLE_MILLI="${ALLOCATABLE_CPU%m}"
else
  ALLOCATABLE_MILLI=$((ALLOCATABLE_CPU * 1000))
fi
# 20 replicas at (allocatable / 8) each = 2.5x the node's real capacity.
PER_POD_MILLI=$((ALLOCATABLE_MILLI / 8))
[ "$PER_POD_MILLI" -lt 100 ] && PER_POD_MILLI=100

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: web, namespace: $NS}
spec:
  replicas: 20
  selector: {matchLabels: {app: web}}
  template:
    metadata: {labels: {app: web}}
    spec:
      nodeSelector: {kubernetes.io/hostname: $WORKER2}
      containers:
      - name: web
        image: nginx:alpine
        resources:
          requests:
            cpu: "${PER_POD_MILLI}m"
YAML

echo "Namespace: $NS — deployment 'web' scaled to 20 replicas (${PER_POD_MILLI}m CPU each) forced onto $WORKER2"
echo "The node has ${ALLOCATABLE_MILLI}m allocatable CPU: several replicas will stay Pending."
