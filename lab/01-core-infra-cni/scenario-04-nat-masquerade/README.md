# Scenario: broken SNAT/MASQUERADE breaks outbound internet traffic

**Namespace:** `net-lab4`

## Context
A pod needs to call an external API on the internet, but every outbound
request times out. A coworker was "cleaning up" iptables rules on one node
last week and it's suspected they removed something they shouldn't have.

## Objective
Use `tcpdump` and `iptables` (not `kubectl`) to find the missing NAT rule on
the node hosting the pod, and restore outbound connectivity — without
reinstalling Cilium or recreating the node.

## Definition of done
- [ ] A pod in `net-lab4` can successfully `curl` an external HTTPS endpoint
      (e.g. `https://raw.githubusercontent.com`) and get a real HTTP status
      code back, not a timeout

## Getting started

```bash
./setup.sh
kubectl -n net-lab4 exec deploy/client -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' https://raw.githubusercontent.com
# expect it to hang/timeout (curl exit code 28)
```

Useful tools: `docker exec <node> tcpdump ...`, `docker exec <node> iptables -t nat -L -n -v`
(kind nodes are docker containers — you can enter their network namespace directly,
just like you would SSH into a real node).

## Verify

```bash
./verify.sh
```

## Cleanup

```bash
kubectl delete ns net-lab4
```
