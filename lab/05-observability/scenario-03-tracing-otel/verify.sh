#!/usr/bin/env bash
set -euo pipefail
NS=obs-lab3
kubectl -n "$NS" exec deploy/hotrod -- wget -qO- "http://localhost:8080/dispatch?customer=123&nonse=1" >/dev/null 2>&1 || true

TRACES=$(kubectl run trace-check --rm -i --image=nicolaka/netshoot --restart=Never -- \
  curl -s "jaeger.${NS}.svc.cluster.local:16686/api/traces?service=frontend&limit=1" 2>/dev/null || true)

if echo "$TRACES" | grep -q '"traceID"'; then
  echo "OK: Jaeger has at least one recorded trace from the 'frontend' service."
else
  echo "No traces visible yet. Generate real traffic from the hotrod UI (port 8080)."
  exit 1
fi
