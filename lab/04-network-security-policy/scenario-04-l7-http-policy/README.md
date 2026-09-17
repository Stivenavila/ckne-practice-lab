# Escenario: política L7 — solo permitir GET /public

**Namespace:** `sec-lab4`

## Contexto
`api-svc` expone `/public` (lectura) y `/admin` (gestión). Un cliente externo solo
debería poder hacer `GET /public`; cualquier otro método o path debe bloquearse
**a nivel de red** (no confiar en que la app lo valide).

## Objetivo
Crea una `CiliumNetworkPolicy` con reglas L7 HTTP que permita solo `GET /public`
desde el cliente, y bloquee el resto.

## Empezar
```bash
./setup.sh
kubectl -n sec-lab4 exec deploy/client -- curl -s api-svc/public   # hoy pasa
kubectl -n sec-lab4 exec deploy/client -- curl -s api-svc/admin    # hoy también pasa (no debería)
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns sec-lab4
```
