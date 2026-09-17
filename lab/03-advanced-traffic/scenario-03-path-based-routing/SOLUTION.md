```bash
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: path-routes, namespace: traffic-lab3}
spec:
  parentRefs: [{name: main-gateway}]
  rules:
  - matches: [{path: {type: PathPrefix, value: "/orders"}}]
    backendRefs: [{name: orders-svc, port: 80}]
  - matches: [{path: {type: PathPrefix, value: "/inventory"}}]
    backendRefs: [{name: inventory-svc, port: 80}]
EOF

GW_IP=$(kubectl -n traffic-lab3 get gateway main-gateway -o jsonpath='{.status.addresses[0].value}')
curl -s "http://$GW_IP/orders"
curl -s "http://$GW_IP/inventory"
```
