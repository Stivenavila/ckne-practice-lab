#!/usr/bin/env bash
set -euo pipefail
NS=net-lab3
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

echo "Instalando Multus CNI (manifiesto oficial thick plugin)..."
kubectl apply -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset.yml

kubectl -n kube-system rollout status daemonset/kube-multus-ds --timeout=120s

echo "Multus instalado. Ahora crea en el namespace '$NS':"
echo "  1) una NetworkAttachmentDefinition (tipo bridge)"
echo "  2) un pod con la anotación k8s.v1.cni.cncf.io/networks apuntando a esa NAD"
