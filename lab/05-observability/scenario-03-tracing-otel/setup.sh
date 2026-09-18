#!/usr/bin/env bash
set -euo pipefail
NS=obs-lab3
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: jaeger, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: jaeger}}
  template:
    metadata: {labels: {app: jaeger}}
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:1.60
        ports:
        - {containerPort: 16686, name: ui}
        - {containerPort: 6831, protocol: UDP, name: agent-compact}
        - {containerPort: 4317, name: otlp-grpc}
---
apiVersion: v1
kind: Service
metadata: {name: jaeger, namespace: $NS}
spec:
  selector: {app: jaeger}
  ports:
  - {name: ui, port: 16686, targetPort: 16686}
  - {name: agent-compact, port: 6831, targetPort: 6831, protocol: UDP}
  - {name: otlp-grpc, port: 4317, targetPort: 4317}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: hotrod, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: hotrod}}
  template:
    metadata: {labels: {app: hotrod}}
    spec:
      containers:
      - name: hotrod
        image: jaegertracing/example-hotrod:1.60
        args: ["all"]
        env:
        - {name: JAEGER_AGENT_HOST, value: jaeger}
        - {name: JAEGER_AGENT_PORT, value: "6831"}
        ports: [{containerPort: 8080}]
---
apiVersion: v1
kind: Service
metadata: {name: hotrod, namespace: $NS}
spec: {selector: {app: hotrod}, ports: [{port: 8080, targetPort: 8080}]}
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=jaeger --timeout=120s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=hotrod --timeout=120s
echo "Namespace: $NS ready. hotrod -> jaeger connected."
