# Scenario: exposing a Service with Gateway API

**Namespace:** `svc-lab5`

## Prerequisite (one time per cluster)
Cilium needs Gateway API enabled:

```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set gatewayAPI.enabled=true
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
kubectl -n kube-system rollout restart deployment/cilium-operator
```

## Context
The checkout team needs to expose `checkout-svc` through a shared Gateway,
instead of creating their own LoadBalancer.

## Objective
1. Create a `Gateway` (or use the one `setup.sh` deploys).
2. Create an `HTTPRoute` that routes traffic from the Gateway to `checkout-svc`.
3. Confirm with `curl` through the Gateway's IP that it responds.

## Definition of done
- [ ] `main-gateway` in `svc-lab5` has an IP under `status.addresses`
- [ ] `curl http://<gateway-ip>` returns `checkout-v1`

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
