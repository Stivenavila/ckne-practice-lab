#!/usr/bin/env bash
set -euo pipefail
RESULT=$(kubectl run dnstest-verify --rm -i --image=nicolaka/netshoot --restart=Never -- \
  dig +short app.corp.internal 2>/dev/null || true)
echo "dig result: $RESULT"
if [ "$RESULT" = "172.20.0.99" ]; then
  echo "OK: app.corp.internal resolves correctly through the forward."
else
  echo "Still not resolving. Check the kube-system/coredns Corefile."
  exit 1
fi
