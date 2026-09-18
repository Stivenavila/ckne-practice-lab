# Scenario: leftover kube-proxy fighting Cilium's replacement mode

**Namespace:** cluster-wide (`kube-system`)

## Context
Your cluster was set up with Cilium's `kubeProxyReplacement` (per this repo's
`00-setup` guide), which means kube-proxy should **not** be running — Cilium's
eBPF datapath handles all Service routing on its own. A teammate, unaware of
that, just ran a generic Kubernetes setup guide that reinstalled the
`kube-proxy` DaemonSet "just in case."

## Objective
Confirm Cilium is actually configured for kube-proxy replacement, find the
leftover `kube-proxy` DaemonSet, and remove it — without breaking Service
routing in the process.

## Definition of done
- [ ] No `kube-proxy` DaemonSet or pods exist in `kube-system`
- [ ] `cilium status` reports `KubeProxyReplacement: True`
- [ ] A basic Service call still works after the cleanup (nothing broke)

## Getting started

```bash
./setup.sh
kubectl -n kube-system get ds kube-proxy
kubectl -n kube-system get pods -l k8s-app=kube-proxy
```

## Verify

```bash
./verify.sh
```

## Cleanup

```bash
# nothing scenario-specific to clean up — kube-proxy staying removed is the
# intended end state, matching the rest of this lab's setup
```
