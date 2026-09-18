# Scenario: L7 policy — only allow GET /public

**Namespace:** `sec-lab4`

## Context
`api-svc` exposes `/public` (read) and `/admin` (management). An external
client should only be able to `GET /public`; any other method or path must be
blocked **at the network level** (don't rely on the app validating it).

## Objective
Create a `CiliumNetworkPolicy` with L7 HTTP rules that allows only
`GET /public` from the client, and blocks everything else.

## Getting started
```bash
./setup.sh
kubectl -n sec-lab4 exec deploy/client -- curl -s api-svc/public   # currently passes
kubectl -n sec-lab4 exec deploy/client -- curl -s api-svc/admin    # currently also passes (shouldn't)
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns sec-lab4
```
