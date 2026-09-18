#!/usr/bin/env bash
set -euo pipefail
NS=traffic-lab2
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: llm-inference, namespace: $NS}
spec:
  replicas: 4
  selector: {matchLabels: {app: llm-inference}}
  template:
    metadata: {labels: {app: llm-inference}}
    spec:
      containers:
      - name: server
        image: busybox
        command: ["sh", "-c"]
        args:
          - "mkdir -p /www && echo \$HOSTNAME > /www/index.html && httpd -f -p 5678 -h /www"
        ports: [{containerPort: 5678}]
---
apiVersion: v1
kind: Service
metadata: {name: llm-inference, namespace: $NS}
spec:
  sessionAffinity: None   # BUG: each request can land on a different pod
  selector: {app: llm-inference}
  ports: [{port: 80, targetPort: 5678}]
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: client, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: client}}
  template:
    metadata: {labels: {app: client}}
    spec:
      containers:
      - name: client
        image: nicolaka/netshoot
        command: ["sleep", "infinity"]
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=llm-inference --timeout=90s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=client --timeout=90s
echo "Namespace: $NS ready. Try several curls in a row: you'll see different pod names."
