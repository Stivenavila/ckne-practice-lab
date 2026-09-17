#!/usr/bin/env bash
set -euo pipefail
NS=sec-lab5
ALLOWED=$(kubectl -n "$NS" exec deploy/client -- curl -s -o /dev/null -m 5 -w '%{http_code}' https://raw.githubusercontent.com || echo "000")
BLOCKED=$(kubectl -n "$NS" exec deploy/client -- curl -s -o /dev/null -m 5 -w '%{http_code}' https://example.com || echo "000")
echo "raw.githubusercontent.com -> $ALLOWED (esperado 200/301/302)"
echo "example.com -> $BLOCKED (esperado 000, es decir, timeout/bloqueado)"
if [ "$ALLOWED" != "000" ] && [ "$BLOCKED" = "000" ]; then
  echo "OK: egress restringido correctamente por FQDN."
else
  echo "El egress todavía no está restringido como se espera."
  exit 1
fi
