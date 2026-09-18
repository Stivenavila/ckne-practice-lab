#!/usr/bin/env bash
set -euo pipefail
NS=sec-lab2
SECRET=$(kubectl -n "$NS" get certificate checkout-tls -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)
echo "Certificate Ready: $SECRET"
if [ "$SECRET" != "True" ]; then
  echo "The Certificate isn't Ready yet."
  exit 1
fi

TLS_REF=$(kubectl -n "$NS" get gateway main-gateway -o jsonpath='{.spec.listeners[?(@.protocol=="HTTPS")].tls.certificateRefs[0].name}' 2>/dev/null || true)
echo "Secret referenced on the Gateway: $TLS_REF"
if [ -z "$TLS_REF" ]; then
  echo "The Gateway's HTTPS listener still doesn't reference the TLS Secret."
  exit 1
fi
echo "OK: Certificate Ready and HTTPS listener configured."
