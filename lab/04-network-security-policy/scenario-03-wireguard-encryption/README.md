# Escenario: encriptación transparente entre nodos (WireGuard)

## Contexto
Un auditor reporta que el tráfico entre nodos viaja en texto plano. Seguridad exige
cifrado en tránsito a nivel de red, sin tocar cada aplicación individualmente.

## Objetivo
1. Confirma el problema con `tcpdump` en el toolbox (`hostNetwork`) capturando
   tráfico entre nodos, viendo el payload legible.
2. Activa la encriptación transparente de Cilium (WireGuard).
3. Confirma que el mismo tráfico ya no es legible en claro.

## Empezar
```bash
./setup.sh
# Genera tráfico entre pods de distintos nodos y captúralo:
kubectl exec toolbox-hostnet -- tcpdump -i any -A -c 20 'port 8080' &
kubectl exec deploy/client -- curl -s server.wg-lab:8080
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns wg-lab
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set encryption.enabled=false
```
