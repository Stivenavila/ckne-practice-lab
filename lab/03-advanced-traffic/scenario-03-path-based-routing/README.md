# Scenario: path-based routing with Gateway API

**Namespace:** `traffic-lab3` (requires Gateway API enabled, see
02-service-networking-dns/scenario-05).

## Context
Two teams share the same public domain/Gateway: `/orders` must go to
`orders-svc` and `/inventory` to `inventory-svc`.

## Objective
Create a single `HTTPRoute` with two `matches.path` rules, each pointing at
the right backend.

## Definition of done
- [ ] `GET /orders` through the Gateway returns `orders-backend`
- [ ] `GET /inventory` through the same Gateway returns `inventory-backend`

## Getting started
```bash
./setup.sh
kubectl -n traffic-lab3 get gateway
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns traffic-lab3
```
