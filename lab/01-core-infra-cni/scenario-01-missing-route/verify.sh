#!/usr/bin/env bash
set -euo pipefail
NS=net-lab1
IP_B=$(kubectl -n "$NS" get pod -l app=web-b -o jsonpath='{.items[0].status.podIP}')
if kubectl -n "$NS" exec deploy/web-a -- ping -c 2 -W 2 "$IP_B" >/dev/null 2>&1; then
  echo "OK: conectividad restaurada entre web-a y web-b ($IP_B)."
else
  echo "TODAVÍA FALLA: web-a no puede alcanzar a web-b ($IP_B)."
  exit 1
fi
