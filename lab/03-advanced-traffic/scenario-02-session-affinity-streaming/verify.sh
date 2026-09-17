#!/usr/bin/env bash
set -euo pipefail
NS=traffic-lab2
AFFINITY=$(kubectl -n "$NS" get svc llm-inference -o jsonpath='{.spec.sessionAffinity}')
echo "sessionAffinity actual: $AFFINITY"
if [ "$AFFINITY" != "ClientIP" ]; then
  echo "Todavía no está en ClientIP."
  exit 1
fi

echo "Haciendo 5 peticiones seguidas desde el mismo cliente..."
RESULTS=$(for i in 1 2 3 4 5; do kubectl -n "$NS" exec deploy/client -- wget -qO- llm-inference; echo; done | sort -u | wc -l)
echo "Pods distintos que respondieron: $RESULTS"
if [ "$RESULTS" -eq 1 ]; then
  echo "OK: todas las peticiones fueron al mismo pod."
else
  echo "Las peticiones siguen rotando entre pods distintos."
  exit 1
fi
