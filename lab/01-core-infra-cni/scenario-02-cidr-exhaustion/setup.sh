#!/usr/bin/env bash
set -euo pipefail
NS=net-lab2
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

WORKER2=$(kubectl get nodes -o name | grep worker2 | sed 's#node/##') || true
[ -z "${WORKER2:-}" ] && WORKER2="ckne-worker2"

# Forzamos que todo caiga en un solo nodo pidiendo mucha CPU por réplica,
# de forma que el nodo se quede sin capacidad asignable (Pending real, causa real).
ALLOCATABLE_CPU=$(kubectl get node "$WORKER2" -o jsonpath='{.status.allocatable.cpu}')

cat <<EOF | kubectl apply -f -
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
EOF

echo "Namespace: $NS — deployment 'web' escalado a 20 réplicas forzadas en $WORKER2"
echo "El nodo tiene $ALLOCATABLE_CPU CPU asignable: varias réplicas quedarán Pending."
