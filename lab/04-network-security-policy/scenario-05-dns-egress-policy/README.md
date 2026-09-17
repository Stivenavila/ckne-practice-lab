# Escenario: egress restringido por dominio (toFQDNs)

**Namespace:** `sec-lab5`

## Contexto
Un pod de `sec-lab5` debe poder llamar únicamente a `raw.githubusercontent.com`
hacia afuera del clúster; cualquier otro destino externo debe bloquearse.

## Objetivo
Crea una `CiliumNetworkPolicy` de egress basada en `toFQDNs` que permita solo ese
dominio y bloquee el resto (ej. `example.com`).

## Empezar
```bash
./setup.sh
kubectl -n sec-lab5 exec deploy/client -- curl -s -o /dev/null -w '%{http_code}\n' https://raw.githubusercontent.com
kubectl -n sec-lab5 exec deploy/client -- curl -s -o /dev/null -w '%{http_code}\n' -m 5 https://example.com
# hoy ambos responden (nada está restringido aún)
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns sec-lab5
```
