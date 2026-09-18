#!/usr/bin/env bash
set -euo pipefail
NS=net-lab3
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

echo "Installing Multus CNI (official thick plugin manifest)..."
kubectl apply -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset.yml

kubectl -n kube-system rollout status daemonset/kube-multus-ds --timeout=120s

echo "Multus installed. Now create in the '$NS' namespace:"
echo "  1) a NetworkAttachmentDefinition (type bridge)"
echo "  2) a pod with the k8s.v1.cni.cncf.io/networks annotation pointing at that NAD"
