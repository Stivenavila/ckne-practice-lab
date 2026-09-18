#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab3
# Only keep lines that actually look like an IPv4 address — "kubectl run --rm"
# prints its own "pod ... deleted" confirmation to stdout too, which would
# otherwise pass a bare non-empty check as a false positive.
RESULT=$(kubectl run dnstest-verify --rm -i --image=nicolaka/netshoot --restart=Never -- \
  dig +short "db-0.db.${NS}.svc.cluster.local" 2>/dev/null \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
echo "dig result for db-0: $RESULT"
if [ -n "$RESULT" ]; then
  echo "OK: per-pod DNS is working (headless active)."
else
  echo "db-0.db.$NS.svc.cluster.local still doesn't resolve — check clusterIP: None."
  exit 1
fi
