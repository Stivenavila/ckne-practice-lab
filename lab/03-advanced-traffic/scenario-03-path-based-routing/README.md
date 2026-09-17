# Escenario: enrutamiento por path con Gateway API

**Namespace:** `traffic-lab3` (requiere Gateway API habilitada, ver escenario
02-service-networking-dns/scenario-05).

## Contexto
Dos equipos comparten un mismo dominio/Gateway público: `/orders` debe ir a
`orders-svc` y `/inventory` a `inventory-svc`.

## Objetivo
Crea un único `HTTPRoute` con dos reglas de `matches.path`, cada una apuntando al
backend correcto.

## Empezar
```bash
./setup.sh
kubectl -n traffic-lab3 get gateway
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns traffic-lab3
```
