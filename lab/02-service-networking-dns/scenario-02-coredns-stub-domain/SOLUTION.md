```bash
CORP_DNS_IP=$(kubectl -n svc-lab2 get svc corp-dns -o jsonpath='{.spec.clusterIP}')
kubectl -n kube-system edit configmap coredns
```

Agrega dentro del bloque principal (o como bloque nuevo, ambos son válidos):

```
corp.internal:53 {
    forward . $CORP_DNS_IP
}
```

```bash
kubectl -n kube-system rollout restart deployment coredns
kubectl run dnstest --rm -it --image=nicolaka/netshoot --restart=Never -- dig app.corp.internal
```
