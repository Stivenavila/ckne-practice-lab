#!/usr/bin/env bash
set -euo pipefail
BLOCKED=$(kubectl -n other-ns exec deploy/attacker -- curl -s -m 3 payments-svc.payments 2>&1 || true)
ALLOWED=$(kubectl -n api-gateway exec deploy/gateway-client -- curl -s -m 3 payments-svc.payments 2>&1 || true)

echo "From other-ns: $BLOCKED"
echo "From api-gateway: $ALLOWED"

if echo "$BLOCKED" | grep -qi "payments-ok"; then
  echo "FAIL: other-ns can still reach payments (should be blocked)."
  exit 1
fi
if ! echo "$ALLOWED" | grep -qi "payments-ok"; then
  echo "FAIL: api-gateway can't reach payments (should be allowed)."
  exit 1
fi
echo "OK: blocked from other-ns, allowed from api-gateway."
