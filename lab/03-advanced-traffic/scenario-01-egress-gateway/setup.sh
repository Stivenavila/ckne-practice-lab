#!/usr/bin/env bash
set -euo pipefail
NS=traffic-lab1
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -
kubectl label namespace "$NS" name="$NS" --overwrite

# Nodo designado como "egress node": lo etiquetamos para que la policy lo seleccione.
EGRESS_NODE=$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}')
kubectl label node "$EGRESS_NODE" egress-node=true --overwrite
EGRESS_NODE_IP=$(kubectl get node "$EGRESS_NODE" -o jsonpath='{.status.addresses[?(@.type=="InternalIP")].address}')

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata: {name: client, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: client}}
  template:
    metadata: {labels: {app: client}}
    spec:
      containers:
      - name: client
        image: nicolaka/netshoot
        command: ["sleep", "infinity"]
EOF

kubectl -n "$NS" wait --for=condition=Ready pod -l app=client --timeout=90s

echo "Namespace: $NS listo."
echo "Nodo egress designado: $EGRESS_NODE ($EGRESS_NODE_IP) — ya tiene el label egress-node=true"
echo "Falta: crear la CiliumEgressGatewayPolicy que fuerce el tráfico de $NS por ese nodo."
