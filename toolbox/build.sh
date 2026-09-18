#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

CLUSTER_NAME="${1:-ckne}"

echo "==> Building ckne-toolbox:latest image"
docker build -t ckne-toolbox:latest .

# Detects whether the active cluster is kind or minikube and uses the right
# image-loading mechanism for each (no need to push to any registry).
if kind get clusters 2>/dev/null | grep -qx "${CLUSTER_NAME}"; then
  echo "==> Detected kind cluster '${CLUSTER_NAME}' — loading image with 'kind load'"
  kind load docker-image ckne-toolbox:latest --name "${CLUSTER_NAME}"
elif minikube profile list -o json 2>/dev/null | grep -q "\"Name\": \"${CLUSTER_NAME}\""; then
  echo "==> Detected minikube cluster '${CLUSTER_NAME}' — loading image with 'minikube image load'"
  minikube image load ckne-toolbox:latest -p "${CLUSTER_NAME}"
else
  echo "Couldn't find a kind or minikube cluster named '${CLUSTER_NAME}'."
  echo "Usage: ./build.sh <cluster-name>"
  exit 1
fi

echo "==> Done. Deploy with: kubectl apply -f debug-pod.yaml"
