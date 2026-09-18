#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab3
RESULT=$(kubectl run dnstest-verify --rm -i --image=nicolaka/netshoot --restart=Never -- \
  dig +short "db-0.db.${NS}.svc.cluster.local" 2>/dev/null || true)
echo "dig result for db-0: $RESULT"
if [ -n "$RESULT" ]; then
  echo "OK: per-pod DNS is working (headless active)."
else
  echo "db-0.db.$NS.svc.cluster.local still doesn't resolve — check clusterIP: None."
  exit 1
fi
