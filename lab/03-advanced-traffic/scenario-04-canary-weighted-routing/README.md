# Scenario: canary release with weighted traffic split

**Namespace:** `traffic-lab4`

## Prerequisite (one time per cluster)
Cilium needs Gateway API enabled:

```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set standaloneDnsProxy.enabled=false \
  --set gatewayAPI.enabled=true
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/experimental-install.yaml
# (experimental channel, not standard — Cilium's operator checks for the
# TLSRoute CRD even if you never use it, and it's only in this channel)
kubectl -n kube-system rollout restart deployment/cilium-operator
```

Optional, only if you want to attempt live traffic testing (see the honest
note below): enable Cilium's L2 announcements so the Gateway's
`LoadBalancer` Service gets a real address on your docker network.

```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set standaloneDnsProxy.enabled=false \
  --set l2announcements.enabled=true
kubectl -n kube-system rollout status daemonset/cilium --timeout=120s

# adjust the CIDR to an unused slice of your `docker network inspect kind` subnet
cat <<EOF | kubectl apply -f -
apiVersion: cilium.io/v2alpha1
kind: CiliumLoadBalancerIPPool
metadata: {name: kind-pool}
spec:
  blocks: [{cidr: "172.19.255.0/24"}]
---
apiVersion: cilium.io/v2alpha1
kind: CiliumL2AnnouncementPolicy
metadata: {name: default-l2-policy}
spec:
  loadBalancerIPs: true
  interfaces: ["^eth0$"]
  nodeSelector: {}
EOF
```

## Honest note before you start
On a bare `kind` cluster, the Gateway's `LoadBalancer` Service never gets an
address without something implementing it (a cloud LB, MetalLB, or Cilium's
own L2 announcements feature) — and even with L2 announcements enabled,
reaching the Gateway's dataplane from inside the cluster was unreliable in
testing on this Cilium/Kubernetes version combination (Cilium's Envoy-backed
Gateway implementation didn't register real backends for the LoadBalancer
Service, so `cilium`'s socket-layer datapath rejected connections outright).
**The graded part of this scenario is the `HTTPRoute` configuration itself**
(the weighted `backendRefs`), which is fully verifiable without live traffic.
If you want to also test live traffic splitting, see the L2 announcements
setup in the Prerequisite section below and treat it as a stretch goal — the
exam's real infrastructure (cloud LoadBalancer) doesn't have this rough edge.

## Context
You're about to roll out `checkout` v2. Before shifting 100% of traffic,
policy requires a canary: only 10% of requests should hit v2, the other 90%
keep hitting the proven v1, both served from the same URL.

## Objective
Create an `HTTPRoute` with two weighted `backendRefs` (v1: 90, v2: 10)
pointing at the same Gateway — the configuration real infrastructure would
use to split live traffic 90/10 between both versions.

## Definition of done
- [ ] `checkout-route` has exactly two `backendRefs`: `checkout-v1` with
      `weight: 90` and `checkout-v2` with `weight: 10`

## Getting started

```bash
./setup.sh
kubectl -n traffic-lab4 get gateway
```

## Verify

```bash
./verify.sh
```

## Cleanup

```bash
kubectl delete ns traffic-lab4
```
