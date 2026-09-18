# Scenario: broken resolution for an internal domain

**Namespace:** `svc-lab2` (for the simulated "corporate DNS") — the cluster's
CoreDNS lives in `kube-system`, you'll edit it directly (that's the real-world
behavior).

## Context
Apps can't resolve names under `corp.internal`. That domain should be
forwarded to a "corporate" DNS server — in this lab, a second CoreDNS instance
simulating that authority and answering records for `app.corp.internal`.

## Objective
Add a stub domain / conditional forward in the cluster CoreDNS's Corefile so
that `*.corp.internal` resolves against the simulated corporate DNS.

## Getting started
```bash
./setup.sh
kubectl run dnstest --rm -it --image=nicolaka/netshoot --restart=Never -- \
  dig app.corp.internal
# Should fail (NXDOMAIN / timeout)
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns svc-lab2
kubectl -n kube-system get cm coredns -o yaml   # manually revert the Corefile if you want to leave it clean
```
