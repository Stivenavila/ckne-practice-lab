# Escenario: pods Running pero fuera del balanceo

**Namespace:** `svc-lab4`

## Contexto
`orders-svc` tiene 4 réplicas `Running` pero **ninguna** aparece como endpoint listo
para recibir tráfico.

## Objetivo
Diagnostica por qué las otras 2 no están `ready` como endpoints y corrige la causa
raíz (no bajes el `periodSeconds` a 1 como parche cosmético: entiende y ajusta el
readiness probe correctamente).

## Empezar
```bash
./setup.sh
kubectl -n svc-lab4 get endpointslices -l kubernetes.io/service-name=orders-svc
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns svc-lab4
```
