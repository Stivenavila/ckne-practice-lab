# Escenario: diagnóstico de pods en Pending por capacidad del nodo

**Namespace:** `net-lab2`

## Nota honesta antes de empezar
El podCIDR por defecto de kind es un `/24` (254 IPs) por nodo — casi imposible de
agotar en un laptop sin crear cientos de pods reales. Este escenario reproduce el
**mismo flujo de diagnóstico** (`describe pod` → leer `Events` → `describe node` →
decidir mitigación) usando un límite de `maxPods`/CPU del nodo como causa real de
`Pending`, que es la habilidad que el examen evalúa. Al final tienes los comandos
exactos para el caso real de CIDR agotado (no reproducibles 1:1 en kind).

## Contexto
Un Deployment escalado agresivamente deja varios pods en `Pending` en un nodo
específico.

## Objetivo
1. Confirma con `kubectl describe pod` la causa exacta del `Pending`.
2. Decide y ejecuta la mitigación correcta (¿cordon? ¿reducir réplicas? ¿tolerar en
   otro nodo?) sin simplemente borrar el Deployment.

## Cómo empezar

```bash
./setup.sh
kubectl -n net-lab2 get pods -o wide
```

## Verificar

```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns net-lab2
kubectl uncordon ckne-worker2 2>/dev/null || true
```
