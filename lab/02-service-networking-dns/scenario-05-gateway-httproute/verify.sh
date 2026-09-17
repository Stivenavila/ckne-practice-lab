#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab5
GW_IP=$(kubectl -n "$NS" get gateway main-gateway -o jsonpath='{.status.addresses[0].value}' 2>/dev/null || true)
if [ -z "$GW_IP" ]; then
  echo "El Gateway aún no tiene IP asignada (status.addresses vacío). Revisa 'kubectl -n $NS describe gateway main-gateway'."
  exit 1
fi
RESP=$(kubectl run curltest-verify --rm -i --image=nicolaka/netshoot --restart=Never -- \
  curl -s -m 5 "http://$GW_IP" 2>/dev/null || true)
echo "Respuesta del Gateway ($GW_IP): $RESP"
if echo "$RESP" | grep -q "checkout-v1"; then
  echo "OK: el HTTPRoute enruta correctamente al backend."
else
  echo "Todavía no llega tráfico al backend a través del Gateway."
  exit 1
fi
