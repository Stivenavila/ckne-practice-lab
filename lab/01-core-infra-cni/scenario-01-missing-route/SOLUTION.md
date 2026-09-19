# Reference solution

```bash
NS=net-lab1
kubectl -n $NS get pods -o wide
IP_B=$(kubectl -n $NS get pod -l app=web-b -o jsonpath='{.items[0].status.podIP}')

# The ping fails:
kubectl -n $NS exec deploy/web-a -- ping -c 2 $IP_B

# First confirm Cilium's own routing mode — this determines what "broken
# connectivity between nodes" could even mean:
CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$CILIUM_POD" -c cilium-agent -- cilium status | grep -i routing
# Routing: Network: Tunnel [vxlan]  -> cross-node pod traffic is VXLAN-encapsulated,
# so this ISN'T a missing ip-route problem — check the actual transport instead.

# Capture on the node hosting web-b: are VXLAN packets (udp/8472) arriving at all?
docker exec ckne-worker2 tcpdump -i any -n udp port 8472 -c 10 &
kubectl -n $NS exec deploy/web-a -- ping -c 3 $IP_B || true
wait
# no packets captured — confirms nothing is reaching worker2 on the VXLAN port

# Check the node's firewall rules
docker exec ckne-worker2 iptables -L INPUT -n -v --line-numbers
# a DROP rule for udp/dpt:8472 from the other worker's IP stands out

# Fix: remove it
docker exec ckne-worker2 iptables -D INPUT -p udp --dport 8472 -s <ckne-worker-IP> -j DROP

# Verify
kubectl -n $NS exec deploy/web-a -- ping -c 2 $IP_B
```

**Exam note:** don't assume "connectivity broke between nodes" always means a
missing `ip route`. With Cilium in `native-routing` mode, host routes to
remote pod CIDRs genuinely matter and a missing/deleted route *can* be the
real cause. With the (more common, and kind's default) `tunnel` mode, pod
traffic is encapsulated and forwarded by eBPF regardless of the host's
routing table for the remote pod CIDR — so always check
`cilium status | grep -i routing` first, and let that tell you whether to
chase routes, tunnel/VXLAN transport, or firewall rules on the underlying
node network.
