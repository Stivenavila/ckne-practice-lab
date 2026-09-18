#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab3
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: v1
kind: Service
metadata: {name: db, namespace: $NS}
spec:
  # BUG: should be headless (clusterIP: None) to address each pod via DNS.
  selector: {app: db}
  ports: [{port: 5432}]
---
apiVersion: apps/v1
kind: StatefulSet
metadata: {name: db, namespace: $NS}
spec:
  serviceName: db
  replicas: 3
  selector: {matchLabels: {app: db}}
  template:
    metadata: {labels: {app: db}}
    spec:
      containers:
      - name: db
        image: busybox
        command: ["sleep", "infinity"]
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=db --timeout=90s
echo "Namespace: $NS ready. The 'db' Service has a ClusterIP instead of being headless."
