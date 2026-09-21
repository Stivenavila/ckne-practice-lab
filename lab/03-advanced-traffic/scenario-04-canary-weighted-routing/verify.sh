#!/usr/bin/env bash
set -euo pipefail
NS=traffic-lab4

W1=$(kubectl -n "$NS" get httproute checkout-route -o jsonpath='{.spec.rules[0].backendRefs[?(@.name=="checkout-v1")].weight}' 2>/dev/null || true)
W2=$(kubectl -n "$NS" get httproute checkout-route -o jsonpath='{.spec.rules[0].backendRefs[?(@.name=="checkout-v2")].weight}' 2>/dev/null || true)
echo "checkout-v1 weight: ${W1:-<missing>}   checkout-v2 weight: ${W2:-<missing>}"
if [ "$W1" != "90" ] || [ "$W2" != "10" ]; then
  echo "Weights aren't set to 90/10 yet."
  exit 1
fi

GW_IP=$(kubectl -n "$NS" get gateway main-gateway -o jsonpath='{.status.addresses[0].value}' 2>/dev/null || true)
if [ -z "$GW_IP" ]; then
  echo "Gateway has no IP yet."
  exit 1
fi

# Retry loop: right after a Cilium/Gateway API config change, Envoy can take
# a little while to finish reconciling — don't hard-fail on the first try.
for attempt in 1 2 3; do
  SEEN_V1=0; SEEN_V2=0
  for i in $(seq 1 15); do
    R=$(kubectl run canarytest-verify-$attempt-$i --rm -i --image=nicolaka/netshoot --restart=Never -- curl -s -m 3 "http://$GW_IP" 2>/dev/null || true)
    echo "$R" | grep -q "checkout-v1" && SEEN_V1=1
    echo "$R" | grep -q "checkout-v2" && SEEN_V2=1
  done
  if [ "$SEEN_V1" -eq 1 ] && [ "$SEEN_V2" -eq 1 ]; then
    echo "OK: traffic is actually splitting between both versions (attempt $attempt)."
    exit 0
  fi
  echo "Attempt $attempt: v1 seen=$SEEN_V1 v2 seen=$SEEN_V2 — retrying in 15s..."
  sleep 15
done

echo "Only one version (or neither) responded across 3 attempts — check the HTTPRoute backendRefs and Gateway status."
exit 1
