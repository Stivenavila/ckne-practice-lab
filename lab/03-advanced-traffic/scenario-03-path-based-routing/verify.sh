#!/usr/bin/env bash
set -euo pipefail
NS=traffic-lab3
GW_IP=$(kubectl -n "$NS" get gateway main-gateway -o jsonpath='{.status.addresses[0].value}' 2>/dev/null || true)
if [ -z "$GW_IP" ]; then
  echo "El Gateway aún no tiene IP asignada."
  exit 1
fi

R1=$(kubectl run curltest-orders --rm -i --image=nicolaka/netshoot --restart=Never -- curl -s -m 5 "http://$GW_IP/orders" 2>/dev/null || true)
R2=$(kubectl run curltest-inventory --rm -i --image=nicolaka/netshoot --restart=Never -- curl -s -m 5 "http://$GW_IP/inventory" 2>/dev/null || true)

echo "/orders -> $R1"
echo "/inventory -> $R2"

if echo "$R1" | grep -q orders-backend && echo "$R2" | grep -q inventory-backend; then
  echo "OK: ambos paths enrutan al backend correcto."
else
  echo "El enrutamiento por path todavía no funciona como se espera."
  exit 1
fi
