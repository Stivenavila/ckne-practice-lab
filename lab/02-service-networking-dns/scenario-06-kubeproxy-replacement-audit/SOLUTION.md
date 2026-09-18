```bash
kubectl -n kube-system get ds kube-proxy
# it exists — shouldn't, per this cluster's setup

CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$CILIUM_POD" -c cilium-agent -- cilium status | grep KubeProxyReplacement
# True — confirms Cilium is already handling this, kube-proxy is pure redundancy
# (and a potential source of conflicting iptables rules)

kubectl -n kube-system delete daemonset kube-proxy

# Confirm nothing broke
kubectl run smoke-test --rm -it --image=nicolaka/netshoot --restart=Never -- \
  curl -s -o /dev/null -w '%{http_code}\n' https://kubernetes.default.svc.cluster.local -k
```

**Exam note:** the real risk here isn't just redundancy — kube-proxy's own
iptables rules can shadow or conflict with Cilium's eBPF programs for the
same Service IPs in some scenarios, causing intermittent, hard-to-diagnose
connectivity issues. Whenever you inherit a cluster, checking
`kubeProxyReplacement` status is a five-second sanity check worth doing
early.
