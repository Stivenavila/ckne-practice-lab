```bash
NS=net-lab4
kubectl -n $NS exec deploy/client -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' https://raw.githubusercontent.com
# 000 (timeout)

NODE=$(kubectl -n $NS get pod -l app=client -o jsonpath='{.items[0].spec.nodeName}')

# Confirm packets leave the node but no reply ever comes back (proof it's a
# NAT/return-path problem, not a routing or DNS problem)
docker exec "$NODE" tcpdump -i any -n 'tcp port 443' -c 10 &
kubectl -n $NS exec deploy/client -- curl -s -m 3 https://raw.githubusercontent.com || true
wait

# Check Cilium's own NAT chain — its MASQUERADE rule for cluster-egress
# traffic is missing. Note: Cilium manages its own pod CIDR internally
# (visible here, e.g. 10.0.x.0/24) which can differ from the CIDR
# Node.spec.podCIDR reports, depending on the IPAM mode — don't assume
# they match.
docker exec "$NODE" iptables -t nat -L CILIUM_POST_nat -n -v --line-numbers
```

Two equally valid fixes once you've confirmed the rule is gone from
`CILIUM_POST_nat`:

**Option A — restart the Cilium agent on that node** (recommended: this is
what actually happens in production, Cilium reconciles its own iptables
rules on agent startup):
```bash
kubectl -n kube-system delete pod -l k8s-app=cilium --field-selector spec.nodeName=$NODE
kubectl -n kube-system wait --for=condition=Ready pod -l k8s-app=cilium --field-selector spec.nodeName=$NODE --timeout=90s
```

**Option B — hand-restore the exact rule** (only if you need to fix it
without restarting the agent, e.g. mid-incident):
```bash
docker exec "$NODE" iptables -t nat -A CILIUM_POST_nat \
  -s 10.0.2.0/24 ! -d 10.0.2.0/24 ! -o cilium_+ \
  -m comment --comment "cilium masquerade non-cluster" -j MASQUERADE
# adjust the /24 to whatever "cilium status | grep -A2 IPAM" reports for
# that node — it's Cilium's own allocated range, not necessarily
# Node.spec.podCIDR
```

```bash
kubectl -n $NS exec deploy/client -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' https://raw.githubusercontent.com
```

**Exam note:** in production, don't hand-edit iptables rules that a CNI
manages long-term — Option B is a valid mid-incident stopgap, but the durable
fix is Option A: let the CNI agent reconcile its own state. Verified in this
lab by actually deleting the Cilium pod on the affected node and confirming
the rule reappeared automatically.
