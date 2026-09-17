# Escenario: auditar un bloqueo con Hubble

**Namespace:** `obs-lab1`

## Contexto
`web-orders` reporta fallas intermitentes llamando a `inventory-svc`. Sospechan de
una NetworkPolicy, pero nadie sabe cuál.

## Objetivo
Usa `hubble observe` para confirmar que el tráfico está siendo bloqueado (DROPPED)
y cuál policy es la responsable — sin mirar primero el YAML de las policies.

## Empezar
```bash
./setup.sh
kubectl -n obs-lab1 exec deploy/web-orders -- curl -s -m 3 inventory-svc
# debe fallar
```

## Pistas
```bash
hubble observe --namespace obs-lab1 --verdict DROPPED
hubble observe --namespace obs-lab1 --verdict DROPPED -o json | jq '.flow.Summary // .Summary'
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns obs-lab1
```
