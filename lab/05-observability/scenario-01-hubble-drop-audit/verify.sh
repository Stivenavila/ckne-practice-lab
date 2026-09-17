#!/usr/bin/env bash
set -euo pipefail
NS=obs-lab1
RESULT=$(kubectl -n "$NS" exec deploy/web-orders -- curl -s -m 3 inventory-svc 2>&1 || true)
echo "Resultado curl: $RESULT"
if echo "$RESULT" | grep -qi "inventory-ok"; then
  echo "El tráfico ya pasa: revisa si identificaste correctamente 'deny-cross-app' como causa antes de borrarla."
else
  echo "Sigue bloqueado (esperado si aún no diagnosticaste/corregiste la policy)."
fi
echo ""
echo "Para autoevaluarte, confirma que pudiste ver el DROP con:"
echo "  hubble observe --namespace $NS --verdict DROPPED"
