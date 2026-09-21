```bash
NS=net-lab4
kubectl -n $NS exec deploy/client -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' https://raw.githubusercontent.com
# 000 (timeout)

NODE=$(kubectl -n $NS get pod -l app=client -o jsonpath='{.items[0].spec.nodeName}')

# Confirm packets leave the node but no reply ever comes back
docker exec "$NODE" tcpdump -i any -n 'tcp port 443' -c 10 &
kubectl -n $NS exec deploy/client -- curl -s -m 3 https://raw.githubusercontent.com || true
wait

# Check the FORWARD chain — an overly broad DROP rule for the pod subnet
# on port 443 stands out
docker exec "$NODE" iptables -L FORWARD -n -v --line-numbers | head -10

# Fix: remove it (adjust the subnet to what the rule actually shows)
POD_CIDR=$(kubectl get ciliumnode "$NODE" -o jsonpath='{.spec.ipam.podCIDRs[0]}')
docker exec "$NODE" iptables -D FORWARD -s "$POD_CIDR" -p tcp --dport 443 -j DROP

# Verify
kubectl -n $NS exec deploy/client -- curl -s -m 5 -o /dev/null -w '%{http_code}\n' https://raw.githubusercontent.com
```

**Exam note:** don't assume where a NAT/masquerade problem lives without
checking first. Cilium can implement masquerading either via iptables (a
`CILIUM_POST_nat` chain you can inspect with `iptables -t nat -L`) or
natively in eBPF (`cilium status | grep Masquerading` tells you which) — a
`FORWARD`-chain firewall rule like this one can break egress regardless of
which mode is active, which is exactly why checking `iptables -L FORWARD`
early is worth doing before you go looking for a missing NAT rule that might
not even be the actual mechanism in play on this cluster.
