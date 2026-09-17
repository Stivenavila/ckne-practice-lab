```bash
cat <<EOF | kubectl apply -f -
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
EOF

kubectl -n sec-lab5 exec deploy/client -- curl -s -o /dev/null -m 5 -w '%{http_code}\n' https://raw.githubusercontent.com
kubectl -n sec-lab5 exec deploy/client -- curl -s -o /dev/null -m 5 -w '%{http_code}\n' https://example.com
```

**Nota clave:** siempre debes permitir explícitamente el egress hacia DNS (puerto 53
a CoreDNS) antes de restringir por `toFQDNs` — Cilium necesita ver la resolución DNS
para poder mapear la IP resuelta al FQDN permitido.
