#!/usr/bin/env bash
set -euo pipefail
NS=sec-lab5
ALLOWED=$(kubectl -n "$NS" exec deploy/client -- curl -s -o /dev/null -m 5 -w '%{http_code}' https://raw.githubusercontent.com || echo "000")
BLOCKED=$(kubectl -n "$NS" exec deploy/client -- curl -s -o /dev/null -m 5 -w '%{http_code}' https://example.com || echo "000")
echo "raw.githubusercontent.com -> $ALLOWED (expected 200/301/302)"
echo "example.com -> $BLOCKED (expected 000, i.e. timeout/blocked)"
if [ "$ALLOWED" != "000" ] && [ "$BLOCKED" = "000" ]; then
  echo "OK: egress correctly restricted by FQDN."
else
  echo "Egress still isn't restricted as expected."
  exit 1
fi
