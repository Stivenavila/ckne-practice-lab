```bash
kubectl -n obs-lab3 port-forward svc/hotrod 8080:8080 &
kubectl -n obs-lab3 port-forward svc/jaeger 16686:16686 &

# genera tráfico real
curl -s "http://localhost:8080/dispatch?customer=123&nonse=1"

# busca la traza más reciente del servicio 'frontend'
curl -s "http://localhost:16686/api/traces?service=frontend&limit=1" | \
  jq '.data[0].spans[] | {op: .operationName, ms: (.duration/1000)}'
```

Salida típica: el span `HTTP GET: /route` (llamada del `driver` service al `route`
service) suele concentrar la mayor latencia — es el salto de red "lento" a propósito
en el demo HotROD, el mismo patrón que preguntará el examen ("¿qué salto concentra
el tiempo?").
