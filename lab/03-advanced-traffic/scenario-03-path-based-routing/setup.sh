#!/usr/bin/env bash
set -euo pipefail
NS=traffic-lab3
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: orders, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: orders}}
  template:
    metadata: {labels: {app: orders}}
    spec:
      containers:
      - {name: orders, image: hashicorp/http-echo, args: ["-text=orders-backend"], ports: [{containerPort: 5678}]}
---
apiVersion: v1
kind: Service
metadata: {name: orders-svc, namespace: $NS}
spec: {selector: {app: orders}, ports: [{port: 80, targetPort: 5678}]}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: inventory, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: inventory}}
  template:
    metadata: {labels: {app: inventory}}
    spec:
      containers:
      - {name: inventory, image: hashicorp/http-echo, args: ["-text=inventory-backend"], ports: [{containerPort: 5678}]}
---
apiVersion: v1
kind: Service
metadata: {name: inventory-svc, namespace: $NS}
spec: {selector: {app: inventory}, ports: [{port: 80, targetPort: 5678}]}
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata: {name: main-gateway, namespace: $NS}
spec:
  gatewayClassName: cilium
  listeners:
  - {name: http, protocol: HTTP, port: 80}
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=orders --timeout=90s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=inventory --timeout=90s
echo "Namespace: $NS ready. Missing the HTTPRoute with both path-based rules."
