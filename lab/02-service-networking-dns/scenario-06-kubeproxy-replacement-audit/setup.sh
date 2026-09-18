#!/usr/bin/env bash
set -euo pipefail

echo "Reinstalling kube-proxy (simulating a teammate who didn't know it should stay off)..."
cat <<YAML | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: kube-proxy
  namespace: kube-system
  labels: {k8s-app: kube-proxy}
spec:
  selector: {matchLabels: {k8s-app: kube-proxy}}
  template:
    metadata: {labels: {k8s-app: kube-proxy}}
    spec:
      hostNetwork: true
      containers:
      - name: kube-proxy
        image: registry.k8s.io/kube-proxy:v1.31.0
        command: ["kube-proxy", "--v=2"]
        securityContext: {privileged: true}
YAML

echo "kube-proxy is back. Confirm it's actually unwanted here and remove it."
