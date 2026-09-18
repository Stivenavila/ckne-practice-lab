# Scenario: Running pods but out of the load balancing pool

**Namespace:** `svc-lab4`

## Context
`orders-svc` has 4 `Running` replicas but **none** show up as a ready
endpoint to receive traffic.

## Objective
Diagnose why those pods aren't `ready` as endpoints and fix the root cause
(don't just drop `periodSeconds` to 1 as a cosmetic patch: understand and fix
the readiness probe properly).

## Getting started
```bash
./setup.sh
kubectl -n svc-lab4 get endpointslices -l kubernetes.io/service-name=orders-svc
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns svc-lab4
```
