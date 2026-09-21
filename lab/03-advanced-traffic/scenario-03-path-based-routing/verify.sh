#!/usr/bin/env bash
set -euo pipefail
NS=traffic-lab3
GW_IP=$(kubectl -n "$NS" get gateway main-gateway -o jsonpath='{.status.addresses[0].value}' 2>/dev/null || true)
if [ -z "$GW_IP" ]; then
  echo "The Gateway still has no IP assigned."
  exit 1
fi

# Envoy can take a little while to finish reconciling right after an
# HTTPRoute change — retry a couple times before declaring failure.
for attempt in 1 2 3; do
  R1=$(kubectl run curltest-orders-$attempt --rm -i --image=nicolaka/netshoot --restart=Never -- curl -s -m 5 "http://$GW_IP/orders" 2>/dev/null || true)
  R2=$(kubectl run curltest-inventory-$attempt --rm -i --image=nicolaka/netshoot --restart=Never -- curl -s -m 5 "http://$GW_IP/inventory" 2>/dev/null || true)
  echo "/orders -> $R1"
  echo "/inventory -> $R2"
  if echo "$R1" | grep -q orders-backend && echo "$R2" | grep -q inventory-backend; then
    echo "OK: both paths route to the correct backend."
    exit 0
  fi
  echo "Attempt $attempt didn't route correctly yet — retrying in 10s..."
  sleep 10
done

echo "Path-based routing still isn't working as expected after 3 attempts."
exit 1
