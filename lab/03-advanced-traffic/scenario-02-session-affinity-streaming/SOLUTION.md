```bash
kubectl -n traffic-lab2 patch svc llm-inference -p \
  '{"spec":{"sessionAffinity":"ClientIP","sessionAffinityConfig":{"clientIP":{"timeoutSeconds":3600}}}}'

for i in 1 2 3 4 5; do
  kubectl -n traffic-lab2 exec deploy/client -- wget -qO- llm-inference; echo
done
# Should print the same hostname all 5 times.
```

**Exam note:** `sessionAffinity: ClientIP` works at the Service level
(kube-proxy/eBPF). If you expose the same service via Gateway API/HTTPRoute,
the equivalent mechanism is a `BackendLBPolicy`/session persistence at the
Gateway level, not on the Service.
