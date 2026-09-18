# Scenario: egress restricted by domain (toFQDNs)

**Namespace:** `sec-lab5`

## Context
A pod in `sec-lab5` must only be able to call `raw.githubusercontent.com`
outside the cluster; any other external destination must be blocked.

## Objective
Create a `CiliumNetworkPolicy` egress rule based on `toFQDNs` that allows only
that domain and blocks everything else (e.g. `example.com`).

## Getting started
```bash
./setup.sh
kubectl -n sec-lab5 exec deploy/client -- curl -s -o /dev/null -w '%{http_code}\n' https://raw.githubusercontent.com
kubectl -n sec-lab5 exec deploy/client -- curl -s -o /dev/null -w '%{http_code}\n' -m 5 https://example.com
# today both respond (nothing is restricted yet)
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns sec-lab5
```
