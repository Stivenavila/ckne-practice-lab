#!/usr/bin/env bash
set -euo pipefail
POLICY=$(kubectl get ciliumegressgatewaypolicy egress-lab1 -o name 2>/dev/null || true)
if [ -z "$POLICY" ]; then
  echo "The CiliumEgressGatewayPolicy 'egress-lab1' doesn't exist yet."
  exit 1
fi

echo "Policy found. Checking the applied state on the Cilium agent..."
CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$CILIUM_POD" -c cilium-agent -- cilium bpf egress list || true

echo ""
echo "Recommended manual check (informational, not blocking in kind):"
echo "  kubectl -n traffic-lab1 exec deploy/client -- curl -s ifconfig.me"
echo "OK if the policy exists and 'cilium bpf egress list' shows an entry for traffic-lab1."
