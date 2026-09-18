#!/usr/bin/env bash
set -euo pipefail
CILIUM_PODS=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}')
FOUND=0
for POD in $CILIUM_PODS; do
  IP=$(kubectl -n kube-system get pod "$POD" -o jsonpath='{.status.podIP}')
  COUNT=$(kubectl run "metrics-verify-$RANDOM" --rm -i --image=nicolaka/netshoot --restart=Never -- \
    curl -s "$IP:9965/metrics" 2>/dev/null | grep -c hubble_drop_total || true)
  echo "Node (agent $POD): hubble_drop_total lines = $COUNT"
  [ "$COUNT" -gt 0 ] && FOUND=1
done

if [ "$FOUND" -eq 1 ]; then
  echo "OK: drop metrics found (manually check which 'destination' has the most)."
else
  echo "No hubble_drop_total metrics found. Did you enable hubble.metrics.enabled?"
  exit 1
fi
