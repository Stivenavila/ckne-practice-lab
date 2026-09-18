#!/usr/bin/env bash
set -euo pipefail
NS=obs-lab4
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace "$NS" name="$NS" --overwrite

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: ledger, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: ledger}}
  template:
    metadata: {labels: {app: ledger}}
    spec: {containers: [{name: ledger, image: hashicorp/http-echo, args: ["-text=ledger-ok"], ports: [{containerPort: 5678}]}]}
---
apiVersion: v1
kind: Service
metadata: {name: ledger-svc, namespace: $NS}
spec: {selector: {app: ledger}, ports: [{port: 80, targetPort: 5678}]}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: billing-client, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: billing-client}}
  template:
    metadata: {labels: {app: billing-client}}
    spec: {containers: [{name: billing-client, image: nicolaka/netshoot, command: ["sleep","infinity"]}]}
---
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata: {name: restrict-ledger, namespace: $NS}
spec:
  endpointSelector:
    matchLabels: {app: ledger}
  ingress:
  - fromEndpoints:
    - matchLabels: {app: audited-caller}
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=ledger --timeout=90s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=billing-client --timeout=90s

echo "Namespace: $NS ready."
echo "billing-client cannot reach ledger-svc — find out why using 'cilium monitor', not hubble."
