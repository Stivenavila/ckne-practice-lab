#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab4
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
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
          # BUG: probing the wrong port — nothing listens on 9999, http-echo
          # only binds :5678 (per -listen above). Connection refused, always.
          httpGet: {path: /, port: 9999}
          initialDelaySeconds: 2
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata: {name: orders-svc, namespace: $NS}
spec:
  selector: {app: orders}
  ports: [{port: 80, targetPort: 5678}]
YAML

echo "Namespace: $NS ready. Wait ~20s and notice no pod ever becomes 'ready'."
