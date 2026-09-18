# Scenario: isolating a namespace with default-deny

**Namespace:** `payments`

## Context
`payments` has no NetworkPolicy at all: any pod in the cluster can reach it.
Security wants all traffic blocked by default, with an explicit allow only for
traffic coming from `api-gateway`.

## Objective
1. Create a default-deny ingress NetworkPolicy in `payments`.
2. Create a second policy that explicitly allows traffic from the
   `api-gateway` namespace.
3. Verify both cases: blocked from other namespaces, allowed from
   `api-gateway`.

## Definition of done
- [ ] A pod in `other-ns` **cannot** reach `payments-svc.payments` (blocked/timeout)
- [ ] A pod in `api-gateway` **can** reach `payments-svc.payments`

## Getting started
```bash
./setup.sh
kubectl -n other-ns exec deploy/attacker -- curl -s -m 3 payments-svc.payments
# Should respond (no policy, everything gets through)
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns payments api-gateway other-ns
```
