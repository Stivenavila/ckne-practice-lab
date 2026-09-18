#!/usr/bin/env bash
set -euo pipefail

for NS in payments api-gateway other-ns; do
  kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -
  kubectl label namespace "$NS" name="$NS" --overwrite
done

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: payments, namespace: payments}
spec:
  replicas: 1
  selector: {matchLabels: {app: payments}}
  template:
    metadata: {labels: {app: payments}}
    spec:
      containers:
      - {name: payments, image: hashicorp/http-echo, args: ["-text=payments-ok"], ports: [{containerPort: 5678}]}
---
apiVersion: v1
kind: Service
metadata: {name: payments-svc, namespace: payments}
spec: {selector: {app: payments}, ports: [{port: 80, targetPort: 5678}]}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: attacker, namespace: other-ns}
spec:
  replicas: 1
  selector: {matchLabels: {app: attacker}}
  template:
    metadata: {labels: {app: attacker}}
    spec: {containers: [{name: attacker, image: nicolaka/netshoot, command: ["sleep","infinity"]}]}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: gateway-client, namespace: api-gateway}
spec:
  replicas: 1
  selector: {matchLabels: {app: gateway-client}}
  template:
    metadata: {labels: {app: gateway-client}}
    spec: {containers: [{name: gateway-client, image: nicolaka/netshoot, command: ["sleep","infinity"]}]}
YAML

kubectl -n payments wait --for=condition=Ready pod -l app=payments --timeout=90s
kubectl -n other-ns wait --for=condition=Ready pod -l app=attacker --timeout=90s
kubectl -n api-gateway wait --for=condition=Ready pod -l app=gateway-client --timeout=90s

echo "Namespaces ready: payments, api-gateway, other-ns. payments has no NetworkPolicy at all."
