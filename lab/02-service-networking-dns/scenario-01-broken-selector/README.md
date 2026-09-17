# Escenario: Service sin endpoints

**Namespace:** `svc-lab1`

## Contexto
`checkout-svc` no enruta tráfico a ningún pod aunque el Deployment tiene réplicas
`Running`.

## Objetivo
Encuentra por qué el Service no tiene endpoints y corrige el selector (no el label
del pod — en el examen real casi siempre el fix correcto es el Service, no forzar
el pod a otro label si ese label ya lo usan otros recursos).

## Empezar
```bash
./setup.sh
kubectl -n svc-lab1 get endpointslices
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns svc-lab1
```
