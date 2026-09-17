```bash
kubectl -n svc-lab4 describe pod -l app=orders | grep -A3 Readiness
# Readiness probe failed: HTTP probe failed with statuscode: 404

kubectl -n svc-lab4 patch deployment orders --type=json \
  -p '[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/"}]'

kubectl -n svc-lab4 get endpointslices -l kubernetes.io/service-name=orders-svc
```
