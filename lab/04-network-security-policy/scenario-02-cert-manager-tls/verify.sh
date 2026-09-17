#!/usr/bin/env bash
set -euo pipefail
NS=sec-lab2
SECRET=$(kubectl -n "$NS" get certificate checkout-tls -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)
echo "Certificate Ready: $SECRET"
if [ "$SECRET" != "True" ]; then
  echo "El Certificate todavía no está Ready."
  exit 1
fi

TLS_REF=$(kubectl -n "$NS" get gateway main-gateway -o jsonpath='{.spec.listeners[?(@.protocol=="HTTPS")].tls.certificateRefs[0].name}' 2>/dev/null || true)
echo "Secret referenciado en el Gateway: $TLS_REF"
if [ -z "$TLS_REF" ]; then
  echo "El listener HTTPS del Gateway aún no referencia el Secret TLS."
  exit 1
fi
echo "OK: Certificate Ready y listener HTTPS configurado."
