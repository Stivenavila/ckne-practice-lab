#!/usr/bin/env bash
set -euo pipefail
NS=sec-lab6
ALLOWED=$(kubectl -n "$NS" exec deploy/client -- nc -zv -w3 1.1.1.1 443 2>&1 || true)
BLOCKED=$(kubectl -n "$NS" exec deploy/client -- nc -zv -w3 8.8.8.8 443 2>&1 || true)
echo "1.1.1.1:443 -> $ALLOWED"
echo "8.8.8.8:443 -> $BLOCKED"

if ! echo "$ALLOWED" | grep -qi "succeeded\|open"; then
  echo "FAIL: client can't reach 1.1.1.1:443 (should be allowed)."
  exit 1
fi
if echo "$BLOCKED" | grep -qi "succeeded\|open"; then
  echo "FAIL: client can still reach 8.8.8.8:443 (should be blocked)."
  exit 1
fi
echo "OK: only 1.1.1.1:443 is reachable."
