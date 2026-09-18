#!/usr/bin/env bash
set -euo pipefail
NS=obs-lab2
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
metadata: {name: noisy-client, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: noisy-client}}
  template:
    metadata: {labels: {app: noisy-client}}
    spec: {containers: [{name: noisy-client, image: nicolaka/netshoot, command: ["sh","-c","while true; do curl -s -m 1 inventory-svc >/dev/null; sleep 0.2; done"]}]}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: block-noisy, namespace: $NS}
spec:
  podSelector: {matchLabels: {app: inventory}}
  policyTypes: [Ingress]
  ingress:
  - from: [{podSelector: {matchLabels: {app: nobody}}}]
YAML

echo "Namespace: $NS ready. 'noisy-client' keeps generating blocked traffic towards inventory-svc."
echo "Wait ~30s for drops to accumulate in Hubble's metrics."
