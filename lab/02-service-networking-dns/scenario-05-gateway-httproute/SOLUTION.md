```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: checkout-route, namespace: svc-lab5}
spec:
  parentRefs:
  - name: main-gateway
  rules:
  - backendRefs:
    - name: checkout-svc
      port: 80
EOF

kubectl -n svc-lab5 get gateway main-gateway
GW_IP=$(kubectl -n svc-lab5 get gateway main-gateway -o jsonpath='{.status.addresses[0].value}')
curl -s "http://$GW_IP"
```
