#!/usr/bin/env bash
set -euo pipefail
NS=wg-lab
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

WORKER1=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')
WORKER2=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[1].metadata.name}')

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: server, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: server}}
  template:
    metadata: {labels: {app: server}}
    spec:
      nodeSelector: {kubernetes.io/hostname: $WORKER1}
      containers:
      - {name: server, image: hashicorp/http-echo, args: ["-text=plaintext-secret-data", "-listen=:8080"], ports: [{containerPort: 8080}]}
---
apiVersion: v1
kind: Service
metadata: {name: server, namespace: $NS}
spec: {selector: {app: server}, ports: [{port: 8080}]}
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
      nodeSelector: {kubernetes.io/hostname: $WORKER2}
      containers:
      - {name: client, image: nicolaka/netshoot, command: ["sleep", "infinity"]}
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=server --timeout=90s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=client --timeout=90s

echo "Namespace: $NS ready. server on $WORKER1, client on $WORKER2 (traffic crosses nodes)."
echo "Deploy the hostNetwork toolbox (../../toolbox/debug-pod.yaml) to capture traffic between nodes."
