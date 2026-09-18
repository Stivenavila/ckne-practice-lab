#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab5
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: checkout, namespace: $NS}
spec:
  replicas: 2
  selector: {matchLabels: {app: checkout}}
  template:
    metadata: {labels: {app: checkout}}
    spec:
      containers:
      - name: checkout
        image: hashicorp/http-echo
        args: ["-text=checkout-v1"]
        ports: [{containerPort: 5678}]
---
apiVersion: v1
kind: Service
metadata: {name: checkout-svc, namespace: $NS}
spec:
  selector: {app: checkout}
  ports: [{port: 80, targetPort: 5678}]
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: main-gateway, namespace: $NS}
spec:
  gatewayClassName: cilium
  listeners:
  - name: http
    protocol: HTTP
    port: 80
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=checkout --timeout=90s
echo "Namespace: $NS ready. You still need to create the HTTPRoute pointing at the Gateway."
