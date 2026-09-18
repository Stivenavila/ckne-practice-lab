```bash
kubectl -n obs-lab3 port-forward svc/hotrod 8080:8080 &
kubectl -n obs-lab3 port-forward svc/jaeger 16686:16686 &

# generate real traffic
curl -s "http://localhost:8080/dispatch?customer=123&nonse=1"

# find the most recent trace from the 'frontend' service
curl -s "http://localhost:16686/api/traces?service=frontend&limit=1" | \
  jq '.data[0].spans[] | {op: .operationName, ms: (.duration/1000)}'
```

Typical output: the `HTTP GET: /route` span (the `driver` service's call to the
`route` service) usually concentrates most of the latency — it's the
intentionally "slow" hop in the HotROD demo, the same pattern the exam will
ask about ("which hop is concentrating the time?").
