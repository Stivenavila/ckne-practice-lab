```bash
# 1. Confirm plaintext traffic (before the fix)
kubectl apply -f ../../toolbox/debug-pod.yaml   # toolbox-hostnet
kubectl exec toolbox-hostnet -- tcpdump -i any -A -c 20 'port 8080' &
kubectl -n wg-lab exec deploy/client -- curl -s server:8080
wait
# you should see "plaintext-secret-data" readable in the dump

# 2. Enable WireGuard
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set encryption.enabled=true --set encryption.type=wireguard
kubectl -n kube-system rollout status daemonset/cilium --timeout=180s

CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$CILIUM_POD" -c cilium-agent -- cilium status | grep Encryption

# 3. Confirm it's no longer readable
kubectl exec toolbox-hostnet -- tcpdump -i any -A -c 20 'port 8080' &
kubectl -n wg-lab exec deploy/client -- curl -s server:8080
wait
# the payload should now be encrypted (or the visible traffic goes through cilium_wg0)
```
