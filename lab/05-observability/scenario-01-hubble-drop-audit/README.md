# Scenario: auditing a block with Hubble

**Namespace:** `obs-lab1`

## Context
`web-orders` reports intermittent failures calling `inventory-svc`. They
suspect a NetworkPolicy, but nobody knows which one.

## Objective
Use `hubble observe` to confirm that traffic is being blocked (DROPPED) and
which policy is responsible — without looking at the policies' YAML first.

## Definition of done
- [ ] You used `hubble observe --verdict DROPPED` to identify `deny-cross-ns` as the blocking policy (before looking at any policy YAML)
- [ ] After the fix, `web-orders` can reach `inventory-svc`

## Getting started
```bash
./setup.sh
kubectl -n obs-lab1 exec deploy/web-orders -- curl -s -m 3 inventory-svc
# should fail
```

## Hints
```bash
hubble observe --namespace obs-lab1 --verdict DROPPED
hubble observe --namespace obs-lab1 --verdict DROPPED -o json | jq '.flow.Summary // .Summary'
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns obs-lab1
```
