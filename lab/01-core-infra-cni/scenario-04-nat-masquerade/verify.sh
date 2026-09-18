#!/usr/bin/env bash
set -euo pipefail
NS=net-lab4
CODE=$(kubectl -n "$NS" exec deploy/client -- curl -s -m 5 -o /dev/null -w '%{http_code}' https://raw.githubusercontent.com 2>/dev/null || true)
echo "HTTP status: $CODE"
if [ "$CODE" != "000" ]; then
  echo "OK: outbound internet connectivity restored."
else
  echo "Still timing out — check the node's NAT table."
  exit 1
fi
