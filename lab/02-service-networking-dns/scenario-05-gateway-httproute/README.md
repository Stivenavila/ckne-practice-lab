# Escenario: exponer un Service con Gateway API

**Namespace:** `svc-lab5`

## Requisito previo (una sola vez por clúster)
Cilium debe tener la Gateway API habilitada:

```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set gatewayAPI.enabled=true
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml
kubectl -n kube-system rollout restart deployment/cilium-operator
```

## Contexto
El equipo de checkout necesita exponer `checkout-svc` a través de un Gateway
compartido, en vez de crear un LoadBalancer propio.

## Objetivo
1. Crea un `Gateway` (o usa el que despliega `setup.sh`).
2. Crea un `HTTPRoute` que enrute el tráfico del Gateway hacia `checkout-svc`.
3. Confirma con `curl` a través de la IP del Gateway que responde.

## Empezar
```bash
./setup.sh
kubectl -n svc-lab5 get gateway
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns svc-lab5
```
