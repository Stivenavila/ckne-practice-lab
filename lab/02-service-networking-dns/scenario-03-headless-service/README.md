# Escenario: headless Service que no expone registros por pod

**Namespace:** `svc-lab3`

## Contexto
Un StatefulSet de 3 réplicas necesita que cada pod sea direccionable individualmente
por DNS (`pod-0.svc...`, `pod-1.svc...`), pero el Service actual está devolviendo un
único registro A tipo round-robin en vez de un registro por pod.

## Objetivo
Corrige el Service para que sea realmente *headless* (`clusterIP: None`) y confirma
que DNS resuelve un registro A por cada pod del StatefulSet.

## Empezar
```bash
./setup.sh
kubectl run dnstest --rm -it --image=nicolaka/netshoot --restart=Never -- \
  dig +short db.svc-lab3.svc.cluster.local
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns svc-lab3
```
