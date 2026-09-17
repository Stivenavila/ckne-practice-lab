#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab3
RESULT=$(kubectl run dnstest-verify --rm -i --image=nicolaka/netshoot --restart=Never -- \
  dig +short "db-0.db.${NS}.svc.cluster.local" 2>/dev/null || true)
echo "Resultado dig db-0: $RESULT"
if [ -n "$RESULT" ]; then
  echo "OK: DNS por pod individual funciona (headless activo)."
else
  echo "Todavía no resuelve db-0.db.$NS.svc.cluster.local — revisa clusterIP: None."
  exit 1
fi
