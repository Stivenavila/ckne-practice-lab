#!/usr/bin/env bash
set -euo pipefail
NS=obs-lab4
RESULT=$(kubectl -n "$NS" exec deploy/billing-client -- curl -s -m 3 ledger-svc 2>&1 || true)
echo "curl result: $RESULT"
if echo "$RESULT" | grep -qi "ledger-ok"; then
  echo "OK: billing-client can now reach ledger-svc."
else
  echo "Still blocked — check the CiliumNetworkPolicy 'restrict-ledger' in $NS."
  exit 1
fi
