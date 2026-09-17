# Escenario: detectar el servicio con más drops usando métricas

**Namespace:** `obs-lab2`

## Requisito previo (una sola vez por clúster)
```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set hubble.metrics.enabled="{drop,tcp,flow}" \
  --set hubble.metrics.enableOpenMetrics=true
kubectl -n kube-system rollout restart daemonset/cilium
```

## Contexto
"La red se siente lenta" — sin poder señalar qué servicio específico. Antes de
investigar a ciegas, confirma con métricas cuál servicio concentra los drops.

## Objetivo
Consulta directamente el endpoint de métricas de Hubble (formato Prometheus) desde
dentro del clúster y determina qué destino tiene más `hubble_drop_total`.

## Empezar
```bash
./setup.sh
CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
CILIUM_IP=$(kubectl -n kube-system get pod "$CILIUM_POD" -o jsonpath='{.status.podIP}')
kubectl run metrics-check --rm -it --image=nicolaka/netshoot --restart=Never -- \
  curl -s "$CILIUM_IP:9965/metrics" | grep hubble_drop_total
```

## Pistas
Repite la consulta de métricas contra **cada** agente Cilium (uno por nodo) y suma
por `destination`, o filtra por el label `destination` que reporte el mayor
`hubble_drop_total`. En un clúster real, esto normalmente lo automatiza Prometheus
con una query `topk(3, sum(rate(hubble_drop_total[5m])) by (destination))`.

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns obs-lab2
```
