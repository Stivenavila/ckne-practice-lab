# Reference solution (kind-reproduced version)

```bash
NS=net-lab2
kubectl -n $NS get pods -o wide | grep Pending
kubectl -n $NS describe pod <a-pending-pod>
# Events: 0/1 nodes are available: 1 Insufficient cpu.

kubectl describe node ckne-worker2 | grep -A5 "Allocated resources"

# Mitigation: reduce replicas to what the node can support, or remove the
# nodeSelector so the scheduler can use other nodes.
kubectl -n $NS scale deployment web --replicas=6
# or:
kubectl -n $NS patch deployment web --type=json \
  -p '[{"op":"remove","path":"/spec/template/spec/nodeSelector"}]'
```

## Real case: exhausted podCIDR (not reproducible 1:1 in kind)

```bash
kubectl describe pod <pending-pod>
# Warning  FailedScheduling  no available IP addresses in range 10.244.4.0/26

kubectl describe node node-4 | grep -A2 PodCIDR
# very small podCIDR (/26 = 62 IPs) for the desired pod density

# Immediate mitigation: take the node out of scheduling while you fix it
kubectl cordon node-4

# Real fix (requires planning, it's not a "hot patch"):
# - Adjust --node-cidr-mask-size on the controller-manager (e.g. from /26 to /24)
# - Or increase the cluster's total range (--cluster-cidr) — usually implies
#   recreating the cluster or the affected nodes.
```
