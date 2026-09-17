#!/usr/bin/env bash
set -euo pipefail
POLICY=$(kubectl get ciliumegressgatewaypolicy egress-lab1 -o name 2>/dev/null || true)
if [ -z "$POLICY" ]; then
  echo "No existe la CiliumEgressGatewayPolicy 'egress-lab1' todavía."
  exit 1
fi

echo "Policy encontrada. Verificando estado aplicado en el agente Cilium..."
CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$CILIUM_POD" -c cilium-agent -- cilium bpf egress list || true

echo ""
echo "Prueba manual recomendada (informativa, no bloqueante en kind):"
echo "  kubectl -n traffic-lab1 exec deploy/client -- curl -s ifconfig.me"
echo "OK si la policy existe y 'cilium bpf egress list' muestra una entrada para traffic-lab1."
