#!/usr/bin/env bash
set -euo pipefail
# Only keep lines that look like an IPv4 address — "kubectl run --rm" prints
# its own "pod ... deleted" confirmation to stdout too, which broke an exact
# string match here even when dig resolved correctly.
RESULT=$(kubectl run dnstest-verify --rm -i --image=nicolaka/netshoot --restart=Never -- \
  dig +short app.corp.internal 2>/dev/null \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' || true)
echo "dig result: $RESULT"
if [ "$RESULT" = "172.20.0.99" ]; then
  echo "OK: app.corp.internal resolves correctly through the forward."
else
  echo "Still not resolving. Check the kube-system/coredns Corefile."
  exit 1
fi
