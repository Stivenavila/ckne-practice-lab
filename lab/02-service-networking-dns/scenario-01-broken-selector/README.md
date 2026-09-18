# Scenario: Service with no endpoints

**Namespace:** `svc-lab1`

## Context
`checkout-svc` isn't routing traffic to any pod even though the Deployment has
`Running` replicas.

## Objective
Find out why the Service has no endpoints and fix the selector (not the pod's
label — on the real exam the correct fix is almost always the Service, not
forcing the pod onto another label that other resources already rely on).

## Definition of done
- [ ] `checkout-svc` in `svc-lab1` has at least one endpoint with `ready: true`

## Getting started
```bash
./setup.sh
kubectl -n svc-lab1 get endpointslices
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns svc-lab1
```
