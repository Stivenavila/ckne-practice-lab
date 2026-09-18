#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab4
READY_COUNT=$(kubectl -n "$NS" get endpointslices -l kubernetes.io/service-name=orders-svc \
  -o jsonpath='{range .items[*].endpoints[*]}{.conditions.ready}{"\n"}{end}' 2>/dev/null | grep -c true || true)
echo "Ready endpoints: $READY_COUNT"
if [ "$READY_COUNT" -ge 1 ]; then
  echo "OK: at least one pod is now ready and receiving traffic."
else
  echo "Still 0 ready endpoints. Check the readinessProbe."
  exit 1
fi
