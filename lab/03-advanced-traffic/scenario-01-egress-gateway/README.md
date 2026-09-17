# Escenario: IP de salida estática con Cilium Egress Gateway

**Namespace:** `traffic-lab1`

## Requisito previo (una sola vez por clúster)
```bash
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set egressGateway.enabled=true
kubectl -n kube-system rollout restart daemonset/cilium
```

## Contexto
Un proveedor externo exige whitelisting por IP fija para todo el tráfico saliente
del namespace `traffic-lab1`.

## Objetivo
Configura una `CiliumEgressGatewayPolicy` que fuerce ese tráfico a salir por un nodo
específico, y confirma con una petición real que la IP de origen observada cambia a
la IP de ese nodo.

## Empezar
```bash
./setup.sh
kubectl -n traffic-lab1 exec deploy/client -- curl -s ifconfig.me
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns traffic-lab1
kubectl delete ciliumegressgatewaypolicy egress-lab1 --ignore-not-found
```
