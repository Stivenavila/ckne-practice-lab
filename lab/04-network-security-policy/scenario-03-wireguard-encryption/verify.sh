#!/usr/bin/env bash
set -euo pipefail
CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
STATUS=$(kubectl -n kube-system exec "$CILIUM_POD" -c cilium-agent -- cilium status 2>/dev/null | grep -i "Encryption" || true)
echo "$STATUS"
if echo "$STATUS" | grep -qi "wireguard"; then
  echo "OK: WireGuard encryption is active."
else
  echo "WireGuard encryption still isn't active."
  exit 1
fi
