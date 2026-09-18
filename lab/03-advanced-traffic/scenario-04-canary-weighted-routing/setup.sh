#!/usr/bin/env bash
set -euo pipefail
NS=traffic-lab4
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: checkout-v1, namespace: $NS}
spec:
  replicas: 2
  selector: {matchLabels: {app: checkout-v1}}
  template:
    metadata: {labels: {app: checkout-v1}}
    spec:
      containers:
      - {name: checkout, image: hashicorp/http-echo, args: ["-text=checkout-v1"], ports: [{containerPort: 5678}]}
---
apiVersion: v1
kind: Service
metadata: {name: checkout-v1, namespace: $NS}
spec: {selector: {app: checkout-v1}, ports: [{port: 80, targetPort: 5678}]}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: checkout-v2, namespace: $NS}
spec:
  replicas: 2
  selector: {matchLabels: {app: checkout-v2}}
  template:
    metadata: {labels: {app: checkout-v2}}
    spec:
      containers:
      - {name: checkout, image: hashicorp/http-echo, args: ["-text=checkout-v2"], ports: [{containerPort: 5678}]}
---
apiVersion: v1
kind: Service
metadata: {name: checkout-v2, namespace: $NS}
spec: {selector: {app: checkout-v2}, ports: [{port: 80, targetPort: 5678}]}
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: main-gateway, namespace: $NS}
spec:
  gatewayClassName: cilium
  listeners:
  - {name: http, protocol: HTTP, port: 80}
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=checkout-v1 --timeout=90s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=checkout-v2 --timeout=90s
echo "Namespace: $NS ready. Both versions are deployed but there's no HTTPRoute splitting traffic yet."
