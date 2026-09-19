#!/usr/bin/env bash
set -euo pipefail
NS=traffic-lab2
AFFINITY=$(kubectl -n "$NS" get svc llm-inference -o jsonpath='{.spec.sessionAffinity}')
echo "Current sessionAffinity: $AFFINITY"
if [ "$AFFINITY" != "ClientIP" ]; then
  echo "Still not set to ClientIP."
  exit 1
fi

echo "Making 5 consecutive requests from the same client..."
# NOTE: the trailing "echo" after each wget was leaking blank lines into the
# output, which "sort -u" then counted as a second "distinct" response
# regardless of whether the pod actually changed — always reporting 2 even
# when every request hit the same pod. grep -v '^$' drops those blank lines.
RESULTS=$(for i in 1 2 3 4 5; do kubectl -n "$NS" exec deploy/client -- wget -qO- llm-inference; echo; done | grep -v '^$' | sort -u | wc -l)
echo "Distinct pods that responded: $RESULTS"
if [ "$RESULTS" -eq 1 ]; then
  echo "OK: every request went to the same pod."
else
  echo "Requests are still rotating between different pods."
  exit 1
fi
