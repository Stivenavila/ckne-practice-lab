#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab1
READY=$(kubectl -n "$NS" get endpointslices -l kubernetes.io/service-name=checkout-svc -o jsonpath='{.items[0].endpoints[*].conditions.ready}' 2>/dev/null || echo "")
if echo "$READY" | grep -q true; then
  echo "OK: checkout-svc now has ready endpoints."
else
  echo "checkout-svc still has no ready endpoints."
  exit 1
fi
