```bash
cat <<YAML | kubectl apply -f -
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
YAML

kubectl -n sec-lab4 exec deploy/client -- curl -s -o /dev/null -w '%{http_code}\n' api-svc/public
kubectl -n sec-lab4 exec deploy/client -- curl -s -o /dev/null -w '%{http_code}\n' api-svc/admin
```

When you define `http` rules in a `CiliumNetworkPolicy`, Cilium injects an
embedded Envoy proxy (visible as `cilium-envoy`) that evaluates L7; anything
that doesn't match any explicit rule gets blocked with a 403 at the proxy
level.
