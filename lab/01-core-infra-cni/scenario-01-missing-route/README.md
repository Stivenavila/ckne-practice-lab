# Escenario: ruta faltante entre nodos

**Namespace:** `net-lab1`

## Contexto
Dos pods (`web-a` en un worker y `web-b` en otro) fueron desplegados. Un compañero
estaba depurando manualmente la tabla de rutas del nodo `ckne-worker2` y dejó una
ruta eliminada por error hacia la subred de pods del otro worker.

## Objetivo
Diagnostica por qué `web-a` no puede alcanzar por ping/curl a `web-b` cruzando nodos,
y restaura la conectividad **sin recrear el clúster ni reinstalar Cilium**.

## Cómo empezar

```bash
./setup.sh
kubectl -n net-lab1 get pods -o wide
kubectl -n net-lab1 exec deploy/web-a -- ping -c 2 <IP-de-web-b>
```

Herramientas útiles: `ip route`, `tcpdump`, `docker exec <nodo> ...` (los nodos de
kind son contenedores docker, puedes entrar a su namespace de red directamente).

## Verificar que quedó resuelto

```bash
./verify.sh
```

## Limpieza

```bash
kubectl delete ns net-lab1
docker exec ckne-worker2 sh -c "ip route add \$(cat /tmp/ckne-broken-route.txt) 2>/dev/null || true"
```
