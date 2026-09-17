```bash
kubectl -n traffic-lab2 patch svc llm-inference -p \
  '{"spec":{"sessionAffinity":"ClientIP","sessionAffinityConfig":{"clientIP":{"timeoutSeconds":3600}}}}'

for i in 1 2 3 4 5; do
  kubectl -n traffic-lab2 exec deploy/client -- wget -qO- llm-inference; echo
done
# Debe imprimir el mismo hostname las 5 veces.
```

**Nota de examen:** `sessionAffinity: ClientIP` funciona a nivel de Service
(kube-proxy/eBPF). Si expones el mismo servicio vía Gateway API/HTTPRoute, el
mecanismo equivalente es un `BackendLBPolicy`/session persistence a nivel de
Gateway, no del Service.
