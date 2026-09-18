#!/usr/bin/env bash
set -euo pipefail
NS=net-lab2
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

WORKER2=$(kubectl get nodes -o name | grep worker2 | sed 's#node/##') || true
[ -z "${WORKER2:-}" ] && WORKER2="ckne-worker2"

# Force everything onto a single node by requesting lots of CPU per replica,
# so the node runs out of allocatable capacity (a real Pending, a real cause).
ALLOCATABLE_CPU=$(kubectl get node "$WORKER2" -o jsonpath='{.status.allocatable.cpu}')

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
            cpu: "300m"
YAML

echo "Namespace: $NS — deployment 'web' scaled to 20 replicas forced onto $WORKER2"
echo "The node has $ALLOCATABLE_CPU allocatable CPU: several replicas will stay Pending."
