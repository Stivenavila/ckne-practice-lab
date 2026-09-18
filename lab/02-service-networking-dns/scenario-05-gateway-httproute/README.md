# Scenario: exposing a Service with Gateway API

**Namespace:** `svc-lab5`

## Prerequisite (one time per cluster)
Cilium needs Gateway API enabled:

```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set standaloneDnsProxy.enabled=false \
  --set gatewayAPI.enabled=true
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/experimental-install.yaml
# (experimental channel, not standard — Cilium's operator checks for the
# TLSRoute CRD even if you never use it, and it's only in this channel)
kubectl -n kube-system rollout restart deployment/cilium-operator
```

## Context
The checkout team needs to expose `checkout-svc` through a shared Gateway,
instead of creating their own LoadBalancer.

## Objective
1. Create a `Gateway` (or use the one `setup.sh` deploys).
2. Create an `HTTPRoute` that routes traffic from the Gateway to `checkout-svc`.
3. Confirm with `curl` through the Gateway's IP that it responds.

## Getting started
```bash
./setup.sh
kubectl -n svc-lab5 get gateway
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns svc-lab5
```
