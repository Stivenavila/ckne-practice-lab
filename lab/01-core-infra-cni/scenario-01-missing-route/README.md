# Scenario: missing route between nodes

**Namespace:** `net-lab1`

## Context
Two pods (`web-a` on one worker, `web-b` on another) were deployed. A
coworker was manually debugging the routing table on node `ckne-worker2` and
accidentally deleted a route to the other worker's pod subnet.

## Objective
Diagnose why `web-a` can't ping/curl `web-b` across nodes, and restore
connectivity **without recreating the cluster or reinstalling Cilium**.

## Getting started

```bash
./setup.sh
kubectl -n net-lab1 get pods -o wide
kubectl -n net-lab1 exec deploy/web-a -- ping -c 2 <web-b-IP>
```

Useful tools: `ip route`, `tcpdump`, `docker exec <node> ...` (kind nodes are
docker containers, you can enter their network namespace directly).

## Verify it's resolved

```bash
./verify.sh
```

## Cleanup

```bash
kubectl delete ns net-lab1
docker exec ckne-worker2 sh -c "ip route add \$(cat /tmp/ckne-broken-route.txt) 2>/dev/null || true"
```
