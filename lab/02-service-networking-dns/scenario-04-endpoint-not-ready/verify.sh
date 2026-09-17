#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab4
READY_COUNT=$(kubectl -n "$NS" get endpointslices -l kubernetes.io/service-name=orders-svc \
  -o jsonpath='{range .items[*].endpoints[*]}{.conditions.ready}{"\n"}{end}' 2>/dev/null | grep -c true || true)
echo "Endpoints ready: $READY_COUNT"
if [ "$READY_COUNT" -ge 1 ]; then
  echo "OK: al menos un pod ya está ready y recibiendo tráfico."
else
  echo "Todavía 0 endpoints ready. Revisa el readinessProbe."
  exit 1
fi
