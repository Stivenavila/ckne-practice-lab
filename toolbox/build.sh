#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

CLUSTER_NAME="${1:-ckne}"

echo "==> Construyendo imagen ckne-toolbox:latest"
docker build -t ckne-toolbox:latest .

# Detecta si el clúster activo es kind o minikube y usa el mecanismo de carga
# de imágenes correcto en cada caso (no hace falta subir a ningún registry).
if kind get clusters 2>/dev/null | grep -qx "${CLUSTER_NAME}"; then
  echo "==> Detectado clúster kind '${CLUSTER_NAME}' — cargando imagen con 'kind load'"
  kind load docker-image ckne-toolbox:latest --name "${CLUSTER_NAME}"
elif minikube profile list -o json 2>/dev/null | grep -q "\"Name\": \"${CLUSTER_NAME}\""; then
  echo "==> Detectado clúster minikube '${CLUSTER_NAME}' — cargando imagen con 'minikube image load'"
  minikube image load ckne-toolbox:latest -p "${CLUSTER_NAME}"
else
  echo "No encontré un clúster kind ni minikube llamado '${CLUSTER_NAME}'."
  echo "Uso: ./build.sh <nombre-del-cluster>"
  exit 1
fi

echo "==> Listo. Despliega con: kubectl apply -f debug-pod.yaml"
