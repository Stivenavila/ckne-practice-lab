#!/usr/bin/env bash
set -euo pipefail
NS=obs-lab1
RESULT=$(kubectl -n "$NS" exec deploy/web-orders -- curl -s -m 3 inventory-svc 2>&1 || true)
echo "curl result: $RESULT"
if echo "$RESULT" | grep -qi "inventory-ok"; then
  echo "Traffic is already getting through: check that you correctly identified 'deny-cross-app' as the cause before deleting it."
else
  echo "Still blocked (expected if you haven't diagnosed/fixed the policy yet)."
fi
echo ""
echo "To self-assess, confirm you were able to see the DROP with:"
echo "  hubble observe --namespace $NS --verdict DROPPED"
