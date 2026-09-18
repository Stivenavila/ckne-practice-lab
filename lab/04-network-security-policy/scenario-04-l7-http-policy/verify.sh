#!/usr/bin/env bash
set -euo pipefail
NS=sec-lab4
PUBLIC=$(kubectl -n "$NS" exec deploy/client -- curl -s -o /dev/null -w '%{http_code}' api-svc/public)
ADMIN=$(kubectl -n "$NS" exec deploy/client -- curl -s -o /dev/null -w '%{http_code}' api-svc/admin)
echo "GET /public -> $PUBLIC (expected 200)"
echo "GET /admin  -> $ADMIN (expected 403)"
if [ "$PUBLIC" = "200" ] && [ "$ADMIN" = "403" ]; then
  echo "OK: the L7 policy filters correctly by path."
else
  echo "The policy still isn't filtering as expected."
  exit 1
fi
