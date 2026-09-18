#!/usr/bin/env bash
set -euo pipefail
NS=obs-lab1
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace "$NS" name="$NS" --overwrite

cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: inventory, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: inventory}}
  template:
    metadata: {labels: {app: inventory}}
    spec: {containers: [{name: inventory, image: hashicorp/http-echo, args: ["-text=inventory-ok"], ports: [{containerPort: 5678}]}]}
---
apiVersion: v1
kind: Service
metadata: {name: inventory-svc, namespace: $NS}
spec: {selector: {app: inventory}, ports: [{port: 80, targetPort: 5678}]}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: web-orders, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: web-orders}}
  template:
    metadata: {labels: {app: web-orders}}
    spec: {containers: [{name: web-orders, image: nicolaka/netshoot, command: ["sleep","infinity"]}]}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: deny-cross-app, namespace: $NS}
spec:
  podSelector: {matchLabels: {app: inventory}}
  policyTypes: [Ingress]
  ingress:
  - from:
    - podSelector: {matchLabels: {app: nonexistent-caller}}
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=inventory --timeout=90s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=web-orders --timeout=90s

echo "Namespace: $NS ready."
echo "Make sure Hubble relay is running: cilium hubble port-forward &"
