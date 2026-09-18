```bash
cat <<YAML | kubectl apply -f -
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata: {name: allow-only-cloudflare-dns, namespace: sec-lab6}
spec:
  endpointSelector:
    matchLabels: {app: client}
  egress:
  # DNS still needs to work for the cluster's own resolution, even though
  # this test doesn't rely on hostnames for the target IPs themselves.
  - toEndpoints:
    - matchLabels: {"k8s:io.kubernetes.pod.namespace": kube-system, "k8s-app": kube-dns}
    toPorts:
    - ports: [{port: "53", protocol: ANY}]
  - toCIDR:
    - "1.1.1.1/32"
    toPorts:
    - ports: [{port: "443", protocol: TCP}]
YAML

kubectl -n sec-lab6 exec deploy/client -- nc -zv -w3 1.1.1.1 443
kubectl -n sec-lab6 exec deploy/client -- nc -zv -w3 8.8.8.8 443   # should now time out
```

**Exam note:** `toCIDR`/`toCIDRSet` is the right tool specifically for
external, non-Kubernetes destinations that only have a stable IP — not for
restricting access to another Service *inside* the cluster. For an in-cluster
destination, prefer `toEndpoints` (label-based) or `toServices`
(`k8sService`/`k8sServiceSelector`), since a Service's ClusterIP is a virtual
address that Cilium's datapath resolves to a backend pod identity before
policy is evaluated — `toCIDR` against a ClusterIP does not reliably work the
way you'd expect.
