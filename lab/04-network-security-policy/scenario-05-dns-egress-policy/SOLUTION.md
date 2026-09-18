```bash
cat <<YAML | kubectl apply -f -
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata: {name: allow-only-github-raw, namespace: sec-lab5}
spec:
  endpointSelector:
    matchLabels: {app: client}
  egress:
  - toEndpoints:
    - matchLabels: {"k8s:io.kubernetes.pod.namespace": kube-system, "k8s-app": kube-dns}
    toPorts:
    - ports: [{port: "53", protocol: ANY}]
      rules:
        dns:
        - matchPattern: "*"
  - toFQDNs:
    - matchName: "raw.githubusercontent.com"
YAML

kubectl -n sec-lab5 exec deploy/client -- curl -s -o /dev/null -m 5 -w '%{http_code}\n' https://raw.githubusercontent.com
kubectl -n sec-lab5 exec deploy/client -- curl -s -o /dev/null -m 5 -w '%{http_code}\n' https://example.com
```

**Key note:** you always need to explicitly allow egress to DNS (port 53 to
CoreDNS) before restricting by `toFQDNs` — Cilium needs to see the DNS
resolution to be able to map the resolved IP back to the allowed FQDN.
