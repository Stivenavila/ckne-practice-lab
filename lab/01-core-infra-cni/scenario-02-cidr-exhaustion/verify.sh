#!/usr/bin/env bash
set -euo pipefail
NS=net-lab2
PENDING=$(kubectl -n "$NS" get pods --field-selector=status.phase=Pending -o name | wc -l)
CORDONED=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.unschedulable}{"\n"}{end}' | grep -c "true" || true)

echo "Remaining Pending pods: $PENDING"
echo "Cordoned nodes: $CORDONED"

if [ "$PENDING" -eq 0 ] || [ "$CORDONED" -ge 1 ]; then
  echo "OK: you diagnosed the cause and applied a mitigation (reduced replicas and/or cordon)."
else
  echo "There are still Pending pods and no node is cordoned. Check 'kubectl describe pod'."
  exit 1
fi
