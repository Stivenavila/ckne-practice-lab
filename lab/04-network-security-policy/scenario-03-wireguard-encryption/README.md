# Scenario: transparent encryption between nodes (WireGuard)

## Context
An auditor reports that traffic between nodes travels in plaintext. Security
requires encryption in transit at the network level, without touching each
application individually.

## Objective
1. Confirm the problem with `tcpdump` on the toolbox (`hostNetwork`),
   capturing traffic between nodes and seeing the readable payload.
2. Enable Cilium's transparent encryption (WireGuard).
3. Confirm that the same traffic is no longer readable in plaintext.

## Getting started
```bash
./setup.sh
# Generate traffic between pods on different nodes and capture it:
kubectl exec toolbox-hostnet -- tcpdump -i any -A -c 20 'port 8080' &
kubectl exec deploy/client -- curl -s server.wg-lab:8080
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns wg-lab
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set encryption.enabled=false
```
