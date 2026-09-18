```bash
cat <<YAML | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny, namespace: payments}
spec:
  podSelector: {}
  policyTypes: [Ingress]
YAML

cat <<YAML | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-api-gateway, namespace: payments}
spec:
  podSelector: {}
  policyTypes: [Ingress]
  ingress:
  - from:
    - namespaceSelector:
        matchLabels: {name: api-gateway}
YAML

kubectl -n other-ns exec deploy/attacker -- curl -s -m 3 payments-svc.payments   # should fail/timeout
kubectl -n api-gateway exec deploy/gateway-client -- curl -s -m 3 payments-svc.payments  # should respond
```
