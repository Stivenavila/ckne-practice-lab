```bash
kubectl -n svc-lab1 get endpointslices -l kubernetes.io/service-name=checkout-svc
kubectl -n svc-lab1 get pods --show-labels
kubectl -n svc-lab1 patch svc checkout-svc -p '{"spec":{"selector":{"app":"checkout"}}}'
kubectl -n svc-lab1 get endpointslices -l kubernetes.io/service-name=checkout-svc
```
