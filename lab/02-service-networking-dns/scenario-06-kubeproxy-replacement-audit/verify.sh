#!/usr/bin/env bash
set -euo pipefail
GONE=0
kubectl -n kube-system get ds kube-proxy >/dev/null 2>&1 || GONE=1

CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
REPLACEMENT=$(kubectl -n kube-system exec "$CILIUM_POD" -c cilium-agent -- cilium status 2>/dev/null | grep -i "KubeProxyReplacement" || true)
echo "$REPLACEMENT"

if [ "$GONE" -eq 1 ] && echo "$REPLACEMENT" | grep -qi "true"; then
  echo "OK: kube-proxy removed and Cilium confirms KubeProxyReplacement: True."
else
  echo "Either kube-proxy is still around, or Cilium isn't reporting the replacement as active."
  exit 1
fi
