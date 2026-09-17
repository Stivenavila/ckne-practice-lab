```bash
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: default-deny, namespace: payments}
spec:
  podSelector: {}
  policyTypes: [Ingress]
EOF

cat <<EOF | kubectl apply -f -
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
EOF

kubectl -n other-ns exec deploy/attacker -- curl -s -m 3 payments-svc.payments   # debe fallar/timeout
kubectl -n api-gateway exec deploy/gateway-client -- curl -s -m 3 payments-svc.payments  # debe responder
```
