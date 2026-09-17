#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

CLUSTER_NAME="${1:-ckne}"

echo "==> Construyendo imagen ckne-toolbox:latest"
docker build -t ckne-toolbox:latest .

echo "==> Cargando la imagen en el clúster kind '${CLUSTER_NAME}'"
kind load docker-image ckne-toolbox:latest --name "${CLUSTER_NAME}"

echo "==> Listo. Despliega con: kubectl apply -f debug-pod.yaml"
