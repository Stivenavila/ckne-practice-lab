# Scenario: auditing a drop via the eBPF monitor log (not Hubble)

**Namespace:** `obs-lab4`

## Context
`billing-client` reports intermittent failures calling `ledger-svc`. This
time, assume Hubble relay isn't available (it can be down, not yet deployed,
or simply not your first instinct in a minimal environment) — you need to
find the drop using Cilium's lower-level monitor log instead, the same
`cilium monitor`/`cilium-dbg monitor` tool that exists even on a bare Cilium
install with no Hubble at all.

## Objective
Use `cilium monitor --type drop` (run inside a `cilium-agent` pod via
`kubectl exec`) to catch the dropped flow live, identify the blocking
`CiliumNetworkPolicy`, and fix it.

## Definition of done
- [ ] You captured the drop with `cilium monitor --type drop` (not
      `hubble observe`) and identified which policy caused it
- [ ] After the fix, `billing-client` can reach `ledger-svc`

## Getting started

```bash
./setup.sh
kubectl -n obs-lab4 exec deploy/billing-client -- curl -s -m 3 ledger-svc
# should fail

# cilium monitor only sees datapath events local to the node it runs on —
# make sure you pick the agent running on the SAME node as billing-client
# (or ledger), not just "the first Cilium pod".
NODE=$(kubectl -n obs-lab4 get pod -l app=billing-client -o jsonpath='{.spec.nodeName}')
CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium --field-selector spec.nodeName=$NODE -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec -it "$CILIUM_POD" -c cilium-agent -- cilium monitor --type drop &
# in another terminal, generate traffic again and watch the drop appear here
kubectl -n obs-lab4 exec deploy/billing-client -- curl -s -m 3 ledger-svc
```

## Verify

```bash
./verify.sh
```

## Cleanup

```bash
kubectl delete ns obs-lab4
```
