```bash
# 1. Confirmar tráfico en claro (antes del fix)
kubectl apply -f ../../toolbox/debug-pod.yaml   # toolbox-hostnet
kubectl exec toolbox-hostnet -- tcpdump -i any -A -c 20 'port 8080' &
kubectl -n wg-lab exec deploy/client -- curl -s server:8080
wait
# deberías ver "plaintext-secret-data" legible en el dump

# 2. Activar WireGuard
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set encryption.enabled=true --set encryption.type=wireguard
kubectl -n kube-system rollout status daemonset/cilium --timeout=180s

CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$CILIUM_POD" -c cilium-agent -- cilium status | grep Encryption

# 3. Confirmar que ya no es legible
kubectl exec toolbox-hostnet -- tcpdump -i any -A -c 20 'port 8080' &
kubectl -n wg-lab exec deploy/client -- curl -s server:8080
wait
# el payload ahora debería estar cifrado (o el tráfico visible pasa por cilium_wg0)
```
