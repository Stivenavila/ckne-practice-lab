#!/usr/bin/env bash
set -euo pipefail
NS=net-lab2
PENDING=$(kubectl -n "$NS" get pods --field-selector=status.phase=Pending -o name | wc -l)
CORDONED=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.unschedulable}{"\n"}{end}' | grep -c "true" || true)

echo "Pods Pending restantes: $PENDING"
echo "Nodos cordoned: $CORDONED"

if [ "$PENDING" -eq 0 ] || [ "$CORDONED" -ge 1 ]; then
  echo "OK: diagnosticaste la causa y aplicaste una mitigación (reducir réplicas y/o cordon)."
else
  echo "Todavía hay pods Pending y ningún nodo está cordoned. Revisa 'kubectl describe pod'."
  exit 1
fi
