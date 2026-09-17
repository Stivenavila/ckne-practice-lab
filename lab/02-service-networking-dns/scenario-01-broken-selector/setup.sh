#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab1
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: web-checkout, namespace: $NS}
spec:
  replicas: 2
  selector: {matchLabels: {app: checkout}}
  template:
    metadata: {labels: {app: checkout}}
    spec:
      containers:
      - name: web
        image: hashicorp/http-echo
        args: ["-text=checkout-ok"]
        ports: [{containerPort: 5678}]
---
apiVersion: v1
kind: Service
metadata: {name: checkout-svc, namespace: $NS}
spec:
  selector: {app: checkout-service}
  ports: [{port: 80, targetPort: 5678}]
EOF

kubectl -n "$NS" wait --for=condition=Ready pod -l app=checkout --timeout=90s
echo "Namespace: $NS listo. El selector del Service no coincide con el label real."
