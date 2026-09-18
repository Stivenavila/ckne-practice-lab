```bash
cat <<YAML | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata: {name: checkout-route, namespace: traffic-lab4}
spec:
  parentRefs: [{name: main-gateway}]
  rules:
  - backendRefs:
    - {name: checkout-v1, port: 80, weight: 90}
    - {name: checkout-v2, port: 80, weight: 10}
YAML

GW_IP=$(kubectl -n traffic-lab4 get gateway main-gateway -o jsonpath='{.status.addresses[0].value}')
for i in $(seq 1 15); do curl -s "http://$GW_IP"; echo; done
# most responses "checkout-v1", a minority "checkout-v2"
```
