# Scenario: headless Service that doesn't expose per-pod records

**Namespace:** `svc-lab3`

## Context
A 3-replica StatefulSet needs each pod to be individually addressable via DNS
(`pod-0.svc...`, `pod-1.svc...`), but the current Service is returning a
single round-robin A record instead of one record per pod.

## Objective
Fix the Service so it's actually *headless* (`clusterIP: None`) and confirm
that DNS resolves one A record per StatefulSet pod.

## Getting started
```bash
./setup.sh
kubectl run dnstest --rm -it --image=nicolaka/netshoot --restart=Never -- \
  dig +short db.svc-lab3.svc.cluster.local
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns svc-lab3
```
