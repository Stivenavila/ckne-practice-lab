#!/usr/bin/env bash
set -euo pipefail
NS=net-lab3
POD=$(kubectl -n "$NS" get pods -l app=capture -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
if [ -z "$POD" ]; then
  echo "No encuentro un pod con label app=capture en $NS. Crea el pod primero."
  exit 1
fi
IFACES=$(kubectl -n "$NS" exec "$POD" -- ip -o link show | wc -l)
echo "Interfaces detectadas en $POD: $IFACES"
if [ "$IFACES" -ge 3 ]; then   # lo, eth0, net1
  echo "OK: el pod tiene una interfaz secundaria activa."
else
  echo "Todavía solo tiene la interfaz por defecto."
  exit 1
fi
