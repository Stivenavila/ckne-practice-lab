```bash
kubectl -n svc-lab4 describe pod -l app=orders | grep -A3 Readiness
# Readiness probe failed: dial tcp <pod-ip>:9999: connect: connection refused

kubectl -n svc-lab4 get pod -l app=orders -o jsonpath='{.items[0].spec.containers[0].readinessProbe.httpGet.port}{"\n"}'
kubectl -n svc-lab4 get pod -l app=orders -o jsonpath='{.items[0].spec.containers[0].ports[0].containerPort}{"\n"}'
# probe targets 9999, container actually listens on 5678 — mismatch found

kubectl -n svc-lab4 patch deployment orders --type=json \
  -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":5678}]'

kubectl -n svc-lab4 get endpointslices -l kubernetes.io/service-name=orders-svc
```
