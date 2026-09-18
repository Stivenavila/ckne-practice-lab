# Scenario: static egress IP with Cilium Egress Gateway

**Namespace:** `traffic-lab1`

## Prerequisite (one time per cluster)
```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set standaloneDnsProxy.enabled=false \
  --set egressGateway.enabled=true
kubectl -n kube-system rollout restart daemonset/cilium
```

## Context
An external provider requires IP whitelisting for all outbound traffic from
the `traffic-lab1` namespace.

## Objective
Configure a `CiliumEgressGatewayPolicy` that forces that traffic out through a
specific node, and confirm with a real request that the observed source IP
changes to that node's IP.

## Definition of done
- [ ] A `CiliumEgressGatewayPolicy` named `egress-lab1` exists
- [ ] `cilium bpf egress list` (run on any Cilium agent) shows an entry for the `traffic-lab1` namespace

## Getting started
```bash
./setup.sh
kubectl -n traffic-lab1 exec deploy/client -- curl -s ifconfig.me
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns traffic-lab1
kubectl delete ciliumegressgatewaypolicy egress-lab1 --ignore-not-found
```
