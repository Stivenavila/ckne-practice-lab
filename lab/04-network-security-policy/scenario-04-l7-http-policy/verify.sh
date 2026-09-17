#!/usr/bin/env bash
set -euo pipefail
NS=sec-lab4
PUBLIC=$(kubectl -n "$NS" exec deploy/client -- curl -s -o /dev/null -w '%{http_code}' api-svc/public)
ADMIN=$(kubectl -n "$NS" exec deploy/client -- curl -s -o /dev/null -w '%{http_code}' api-svc/admin)
echo "GET /public -> $PUBLIC (esperado 200)"
echo "GET /admin  -> $ADMIN (esperado 403)"
if [ "$PUBLIC" = "200" ] && [ "$ADMIN" = "403" ]; then
  echo "OK: la política L7 filtra correctamente por path."
else
  echo "La política todavía no filtra como se espera."
  exit 1
fi
