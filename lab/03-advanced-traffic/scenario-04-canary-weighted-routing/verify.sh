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
echo "OK: HTTPRoute config is correct (this is the part that's graded)."

# Best-effort live traffic check — informational only, does not affect
# pass/fail. On kind without a real cloud LoadBalancer, Gateway dataplane
# connectivity can be unreliable/version-dependent even with L2
# announcements enabled; see this scenario's README for details.
GW_IP=$(kubectl -n "$NS" get gateway main-gateway -o jsonpath='{.status.addresses[0].value}' 2>/dev/null || true)
if [ -n "$GW_IP" ]; then
  SEEN_V1=0; SEEN_V2=0
  for i in $(seq 1 10); do
    R=$(kubectl run canarytest-verify-$i --rm -i --image=nicolaka/netshoot --restart=Never -- curl -s -m 3 "http://$GW_IP" 2>/dev/null || true)
    echo "$R" | grep -q "checkout-v1" && SEEN_V1=1
    echo "$R" | grep -q "checkout-v2" && SEEN_V2=1
  done
  echo "(informational) live traffic saw v1: $SEEN_V1   v2: $SEEN_V2"
else
  echo "(informational) Gateway has no address yet — skipping live traffic check."
fi
