#!/usr/bin/env bash
set -euo pipefail
NS=net-lab3
POD=$(kubectl -n "$NS" get pods -l app=capture -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
if [ -z "$POD" ]; then
  echo "Can't find a pod with label app=capture in $NS. Create the pod first."
  exit 1
fi
IFACES=$(kubectl -n "$NS" exec "$POD" -- ip -o link show | wc -l)
echo "Interfaces detected on $POD: $IFACES"
if [ "$IFACES" -ge 3 ]; then   # lo, eth0, net1
  echo "OK: the pod has an active secondary interface."
else
  echo "Still only has the default interface."
  exit 1
fi
