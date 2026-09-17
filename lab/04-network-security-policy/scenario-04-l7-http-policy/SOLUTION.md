```bash
cat <<EOF | kubectl apply -f -
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata: {name: allow-only-public-get, namespace: sec-lab4}
spec:
  endpointSelector:
    matchLabels: {app: api}
  ingress:
  - fromEndpoints:
    - matchLabels: {app: client}
    toPorts:
    - ports: [{port: "80", protocol: TCP}]
      rules:
        http:
        - {method: "GET", path: "/public"}
EOF

kubectl -n sec-lab4 exec deploy/client -- curl -s -o /dev/null -w '%{http_code}\n' api-svc/public
kubectl -n sec-lab4 exec deploy/client -- curl -s -o /dev/null -w '%{http_code}\n' api-svc/admin
```

Cuando defines reglas `http` en una `CiliumNetworkPolicy`, Cilium inyecta un proxy
Envoy embebido (visible como `cilium-envoy`) que evalúa L7; todo lo que no matchee
ninguna regla explícita se bloquea con 403 a nivel del proxy.
