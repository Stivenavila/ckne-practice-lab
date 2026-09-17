# Escenario: TLS para un Gateway con cert-manager

**Namespace:** `sec-lab2`

## Requisito previo (una sola vez por clúster)
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl -n cert-manager rollout status deployment/cert-manager --timeout=120s
kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=120s
```

## Contexto
El Gateway de `checkout` sirve tráfico en texto plano. Necesitas terminar TLS con un
certificado gestionado por cert-manager (en este lab, un `ClusterIssuer`
self-signed — sin ACME real porque no hay dominio público en el laboratorio local).

## Objetivo
1. Crea un `ClusterIssuer` self-signed.
2. Crea un `Certificate` para `checkout.lab.local` que genere el Secret TLS.
3. Referencia ese Secret en el listener HTTPS del Gateway.
4. Confirma con `openssl s_client`/`curl -k` que el Gateway ahora sirve TLS.

## Empezar
```bash
./setup.sh
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns sec-lab2
kubectl delete clusterissuer selfsigned-issuer --ignore-not-found
```
