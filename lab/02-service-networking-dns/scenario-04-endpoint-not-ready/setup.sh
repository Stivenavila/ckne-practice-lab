#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab4
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: orders, namespace: $NS}
spec:
  replicas: 4
  selector: {matchLabels: {app: orders}}
  template:
    metadata: {labels: {app: orders}}
    spec:
      containers:
      - name: orders
        image: hashicorp/http-echo
        args: ["-text=orders-ok", "-listen=:5678"]
        ports: [{containerPort: 5678}]
        readinessProbe:
          httpGet: {path: /healthz, port: 5678}   # BUG: http-echo no sirve /healthz -> 404 siempre
          initialDelaySeconds: 2
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata: {name: orders-svc, namespace: $NS}
spec:
  selector: {app: orders}
  ports: [{port: 80, targetPort: 5678}]
EOF

echo "Namespace: $NS listo. Espera ~20s y observa que ningún pod queda 'ready'."
