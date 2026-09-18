# Reference solution

```bash
NS=net-lab1
kubectl -n $NS get pods -o wide
IP_A=$(kubectl -n $NS get pod -l app=web-a -o jsonpath='{.items[0].status.podIP}')
IP_B=$(kubectl -n $NS get pod -l app=web-b -o jsonpath='{.items[0].status.podIP}')

# The ping fails:
kubectl -n $NS exec deploy/web-a -- ping -c 2 $IP_B

# Diagnosis: enter the node hosting web-b and check its routing table
docker exec ckne-worker2 ip route
# Missing route to the other worker's podCIDR (e.g. 10.244.1.0/24 via the CNI gateway)

# Reference: which podCIDR is "broken"
kubectl get node ckne-worker -o jsonpath='{.spec.podCIDR}'

# Fix: restore the route (adjust the "via" to the real gateway that "ip route" reports on the good node)
docker exec ckne-worker ip route   # copy the valid route pattern from this node
docker exec ckne-worker2 ip route add <WORKER1-PODCIDR> via <CNI-GATEWAY-ON-WORKER2>

# Verify
kubectl -n $NS exec deploy/web-a -- ping -c 2 $IP_B
```

**Exam note:** on a real cluster (not kind), this route is normally managed by
the CNI itself (Cilium programs routes via eBPF or via kernel routing tables
depending on the mode: `tunnel` vxlan/geneve vs `native-routing`). If you see
this symptom in production, before touching routes by hand check:

```bash
cilium status
cilium bpf tunnel list
kubectl -n kube-system logs ds/cilium -c cilium-agent | grep -i route
```
