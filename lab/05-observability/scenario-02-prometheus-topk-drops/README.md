# Scenario: finding the service with the most drops using metrics

**Namespace:** `obs-lab2`

## Prerequisite (one time per cluster)
```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set standaloneDnsProxy.enabled=false \
  --set hubble.metrics.enabled="{drop,tcp,flow}" \
  --set hubble.metrics.enableOpenMetrics=true
kubectl -n kube-system rollout restart daemonset/cilium
```

## Context
"The network feels slow" — without being able to point at a specific service.
Before investigating blindly, confirm it with metrics which service is
concentrating the drops.

## Objective
Query the Hubble metrics endpoint directly (Prometheus format) from inside
the cluster and determine which destination has the most
`hubble_drop_total`.

## Getting started
```bash
./setup.sh
CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
CILIUM_IP=$(kubectl -n kube-system get pod "$CILIUM_POD" -o jsonpath='{.status.podIP}')
kubectl run metrics-check --rm -it --image=nicolaka/netshoot --restart=Never -- \
  curl -s "$CILIUM_IP:9965/metrics" | grep hubble_drop_total
```

## Hints
Repeat the metrics query against **each** Cilium agent (one per node) and sum
by `destination`, or filter for the `destination` label reporting the highest
`hubble_drop_total`. On a real cluster, Prometheus normally automates this
with a `topk(3, sum(rate(hubble_drop_total[5m])) by (destination))` query.

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns obs-lab2
```
