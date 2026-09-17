# Escenario: aislar un namespace con default-deny

**Namespace:** `payments`

## Contexto
`payments` no tiene ninguna NetworkPolicy: cualquier pod del clúster puede
alcanzarlo. Seguridad exige bloquear todo por defecto y permitir solo el tráfico
que venga del namespace `api-gateway`.

## Objetivo
1. Crea una NetworkPolicy default-deny de ingress en `payments`.
2. Crea una segunda policy que permita explícitamente el tráfico desde `api-gateway`.
3. Verifica ambos casos: bloqueado desde otros namespaces, permitido desde
   `api-gateway`.

## Empezar
```bash
./setup.sh
kubectl -n other-ns exec deploy/attacker -- curl -s -m 3 payments-svc.payments
# Debe responder (sin política, todo pasa)
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns payments api-gateway other-ns
```
