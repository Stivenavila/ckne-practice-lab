```bash
CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
CILIUM_IP=$(kubectl -n kube-system get pod "$CILIUM_POD" -o jsonpath='{.status.podIP}')

kubectl run metrics-check --rm -it --image=nicolaka/netshoot --restart=Never -- \
  curl -s "$CILIUM_IP:9965/metrics" | grep hubble_drop_total

# ejemplo de salida:
# hubble_drop_total{destination="inventory-svc",reason="POLICY_DENIED"} 84

hubble observe --namespace obs-lab2 --verdict DROPPED --to-pod inventory
```

## Con un stack Prometheus completo (opcional, para practicar la query real)
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prom prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
kubectl -n monitoring port-forward svc/kube-prom-kube-prometheus-prometheus 9090:9090
# En la UI de Prometheus:
topk(3, sum(rate(hubble_drop_total[5m])) by (destination))
```
