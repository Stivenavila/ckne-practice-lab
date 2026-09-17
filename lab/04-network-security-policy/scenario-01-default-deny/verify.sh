#!/usr/bin/env bash
set -euo pipefail
BLOCKED=$(kubectl -n other-ns exec deploy/attacker -- curl -s -m 3 payments-svc.payments 2>&1 || true)
ALLOWED=$(kubectl -n api-gateway exec deploy/gateway-client -- curl -s -m 3 payments-svc.payments 2>&1 || true)

echo "Desde other-ns: $BLOCKED"
echo "Desde api-gateway: $ALLOWED"

if echo "$BLOCKED" | grep -qi "payments-ok"; then
  echo "FALLA: other-ns todavía puede llegar a payments (debería estar bloqueado)."
  exit 1
fi
if ! echo "$ALLOWED" | grep -qi "payments-ok"; then
  echo "FALLA: api-gateway no puede llegar a payments (debería estar permitido)."
  exit 1
fi
echo "OK: bloqueado desde other-ns, permitido desde api-gateway."
