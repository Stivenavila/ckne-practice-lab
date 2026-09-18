#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab5
GW_IP=$(kubectl -n "$NS" get gateway main-gateway -o jsonpath='{.status.addresses[0].value}' 2>/dev/null || true)
if [ -z "$GW_IP" ]; then
  echo "The Gateway still has no IP assigned (status.addresses is empty). Check 'kubectl -n $NS describe gateway main-gateway'."
  exit 1
fi
RESP=$(kubectl run curltest-verify --rm -i --image=nicolaka/netshoot --restart=Never -- \
  curl -s -m 5 "http://$GW_IP" 2>/dev/null || true)
echo "Gateway response ($GW_IP): $RESP"
if echo "$RESP" | grep -q "checkout-v1"; then
  echo "OK: the HTTPRoute is correctly routing to the backend."
else
  echo "Traffic still isn't reaching the backend through the Gateway."
  exit 1
fi
