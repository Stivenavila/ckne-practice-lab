# Scenario: connections rotating between pods on a "streaming" service

**Namespace:** `traffic-lab2`

## Context
`llm-inference` responds with the name of the pod that handled the request.
The team reports that consecutive calls from the same client keep landing on
different pods, breaking long-lived (streaming) sessions.

## Objective
Confirm the default behavior (round robin across pods) and fix the Service so
requests from the same client stay pinned to the same pod.

## Getting started
```bash
./setup.sh
for i in 1 2 3 4; do
  kubectl -n traffic-lab2 exec deploy/client -- curl -s llm-inference
done
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns traffic-lab2
```
