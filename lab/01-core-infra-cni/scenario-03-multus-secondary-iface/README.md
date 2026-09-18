# Scenario: pod with a second network interface (Multus)

**Namespace:** `net-lab3`

## Context
A data capture workload needs a secondary interface in addition to `eth0`
(the one Cilium manages).

## Objective
1. Install Multus CNI as a meta-plugin.
2. Create a `NetworkAttachmentDefinition` of type `bridge` (more stable in
   Docker/kind than `macvlan`, which tends to fail due to Docker bridge
   restrictions).
3. Create a pod that uses that NAD via the
   `k8s.v1.cni.cncf.io/networks` annotation and confirm with `ip addr` that it
   has two interfaces.

## Definition of done
- [ ] A pod labeled `app=capture` exists in `net-lab3`
- [ ] `kubectl -n net-lab3 exec <pod> -- ip addr` shows **two** interfaces (`eth0` + a second one, e.g. `net1`)

## Getting started

```bash
./setup.sh
```

The script installs Multus (official manifest) and gets the namespace ready.
The rest (creating the NAD and the pod) is on you — those are the two
resources the real exam actually evaluates.

## Hints
```bash
kubectl get network-attachment-definitions -n net-lab3
kubectl -n net-lab3 exec <pod> -- ip addr
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns net-lab3
kubectl delete -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset.yml --ignore-not-found
```
