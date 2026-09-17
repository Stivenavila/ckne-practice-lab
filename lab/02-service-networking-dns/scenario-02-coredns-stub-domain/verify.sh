#!/usr/bin/env bash
set -euo pipefail
RESULT=$(kubectl run dnstest-verify --rm -i --image=nicolaka/netshoot --restart=Never -- \
  dig +short app.corp.internal 2>/dev/null || true)
echo "Resultado dig: $RESULT"
if [ "$RESULT" = "172.20.0.99" ]; then
  echo "OK: app.corp.internal resuelve correctamente vía el forward."
else
  echo "Todavía no resuelve. Revisa el Corefile de kube-system/coredns."
  exit 1
fi
