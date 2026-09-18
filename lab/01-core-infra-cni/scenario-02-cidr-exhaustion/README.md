# Scenario: diagnosing Pending pods due to node capacity

**Namespace:** `net-lab2`

## Honest note before you start
kind's default podCIDR is a `/24` per node (254 IPs) — nearly impossible to
exhaust on a laptop without spinning up hundreds of real pods. This scenario
reproduces the **same diagnostic flow** (`describe pod` → read `Events` →
`describe node` → decide on mitigation) using a node `maxPods`/CPU limit as the
real cause of `Pending`, which is the skill the exam actually tests. At the end
you'll find the exact commands for the real CIDR-exhaustion case (not
reproducible 1:1 in kind).

## Context
An aggressively scaled Deployment leaves several pods `Pending` on a specific
node.

## Objective
1. Confirm with `kubectl describe pod` the exact cause of the `Pending` state.
2. Decide on and apply the correct mitigation (cordon? reduce replicas?
   tolerate on another node?) without simply deleting the Deployment.

## Definition of done
- [ ] No pods remain `Pending` in `net-lab2` (reduced replicas / removed the nodeSelector), **or**
- [ ] The affected node is `cordoned` as an explicit, deliberate mitigation

## Getting started

```bash
./setup.sh
kubectl -n net-lab2 get pods -o wide
```

## Verify

```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns net-lab2
kubectl uncordon ckne-worker2 2>/dev/null || true
```
