# Escenario: resolución rota hacia dominio interno

**Namespace:** `svc-lab2` (para el "DNS corporativo" simulado) — CoreDNS del clúster
vive en `kube-system`, lo vas a editar directamente (es el comportamiento real).

## Contexto
Las apps no logran resolver nombres de `corp.internal`. Ese dominio debería
reenviarse a un servidor DNS "corporativo" — en este lab, un segundo CoreDNS que
simula esa autoridad y responde registros para `app.corp.internal`.

## Objetivo
Agrega un stub domain / forward condicional en el Corefile del CoreDNS del clúster
para que `*.corp.internal` se resuelva contra el DNS corporativo simulado.

## Empezar
```bash
./setup.sh
kubectl run dnstest --rm -it --image=nicolaka/netshoot --restart=Never -- \
  dig app.corp.internal
# Debe fallar (NXDOMAIN / timeout)
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns svc-lab2
kubectl -n kube-system get cm coredns -o yaml   # revierte manualmente el Corefile si quieres dejarlo limpio
```
