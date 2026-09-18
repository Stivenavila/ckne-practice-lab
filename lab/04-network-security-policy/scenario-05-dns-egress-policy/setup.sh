#!/usr/bin/env bash
set -euo pipefail
NS=sec-lab5
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: client, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: client}}
  template:
    metadata: {labels: {app: client}}
    spec: {containers: [{name: client, image: nicolaka/netshoot, command: ["sleep","infinity"]}]}
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=client --timeout=90s
echo "Namespace: $NS ready. Requires the cluster to have internet access (kind usually does)."
echo "There's no egress restriction by domain yet."
