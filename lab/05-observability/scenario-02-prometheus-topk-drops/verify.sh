#!/usr/bin/env bash
set -euo pipefail
CILIUM_PODS=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[*].metadata.name}')
FOUND=0
for POD in $CILIUM_PODS; do
  IP=$(kubectl -n kube-system get pod "$POD" -o jsonpath='{.status.podIP}')
  COUNT=$(kubectl run "metrics-verify-$RANDOM" --rm -i --image=nicolaka/netshoot --restart=Never -- \
    curl -s "$IP:9965/metrics" 2>/dev/null | grep -c hubble_drop_total || true)
  echo "Nodo (agente $POD): líneas hubble_drop_total = $COUNT"
  [ "$COUNT" -gt 0 ] && FOUND=1
done

if [ "$FOUND" -eq 1 ]; then
  echo "OK: se encontraron métricas de drops (revisa manualmente cuál 'destination' concentra más)."
else
  echo "No se encontraron métricas hubble_drop_total. ¿Habilitaste hubble.metrics.enabled?"
  exit 1
fi
