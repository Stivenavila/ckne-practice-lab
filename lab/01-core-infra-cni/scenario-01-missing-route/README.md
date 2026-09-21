# Scenario: firewall blocking overlay traffic between nodes

**Namespace:** `net-lab1`

## Context
Two pods (`web-a` on one worker, `web-b` on another) were deployed. A
coworker was "hardening" host firewall rules on one node last week and
accidentally blocked traffic on the port Cilium's overlay network uses
between nodes.

## Objective
Diagnose why `web-a` can't ping/curl `web-b` across nodes, and restore
connectivity — without recreating the cluster or reinstalling Cilium.

## Definition of done
- [ ] `kubectl -n net-lab1 exec deploy/web-a -- ping -c 2 <web-b-IP>` succeeds with 0% packet loss

## Getting started

```bash
./setup.sh
kubectl -n net-lab1 get pods -o wide
kubectl -n net-lab1 exec deploy/web-a -- ping -c 2 <web-b-IP>
```

Useful tools: `docker exec <node> tcpdump -i any udp port 8472` (Cilium's
default VXLAN port — kind nodes are docker containers, you can enter their
network namespace directly), `docker exec <node> iptables -L -n -v`.

## Verify

```bash
./verify.sh
```

## Cleanup

```bash
kubectl delete ns net-lab1
# if you didn't already remove it as part of solving the scenario:
docker exec ckne-worker2 iptables -S INPUT | grep 8472
```
