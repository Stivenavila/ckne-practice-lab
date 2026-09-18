# Scenario: end-to-end tracing of a slow request

**Namespace:** `obs-lab3`

## Context
We use Jaeger's official "HotROD" demo (a ride-hailing app with 4 internal
services: frontend → driver → customer → route), which emits real
multi-service traces. One of its internal hops is intentionally slow — just
like the exam's scenario ("which network hop is concentrating the latency?").

## Objective
1. Generate a real request against the app.
2. Find that request's trace-id.
3. In the Jaeger UI, identify which span is responsible for most of the total
   latency.

## Getting started
```bash
./setup.sh
kubectl -n obs-lab3 port-forward svc/hotrod 8080:8080 &
kubectl -n obs-lab3 port-forward svc/jaeger 16686:16686 &
```

Open http://localhost:8080, request a ride ("Call a car" button), then look
up the trace at http://localhost:16686.

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns obs-lab3
```
