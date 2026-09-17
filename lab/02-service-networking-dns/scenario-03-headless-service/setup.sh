#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab3
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata: {name: db, namespace: $NS}
spec:
  # BUG: debería ser headless (clusterIP: None) para direccionar cada pod por DNS.
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
EOF

kubectl -n "$NS" wait --for=condition=Ready pod -l app=db --timeout=90s
echo "Namespace: $NS listo. El Service 'db' tiene ClusterIP en vez de ser headless."
