# Escenario: tracing end-to-end de una petición lenta

**Namespace:** `obs-lab3`

## Contexto
Usamos el demo oficial de Jaeger "HotROD" (una app de pedir un taxi con 4 servicios
internos: frontend → driver → customer → route), que emite trazas reales
multi-servicio. Uno de sus saltos internos es intencionalmente lento — igual que en
el escenario del examen ("¿en qué salto de red se concentra la latencia?").

## Objetivo
1. Genera una petición real contra la app.
2. Encuentra el trace-id de esa petición.
3. En la UI de Jaeger, identifica qué span concentra la mayor parte de la latencia
   total.

## Empezar
```bash
./setup.sh
kubectl -n obs-lab3 port-forward svc/hotrod 8080:8080 &
kubectl -n obs-lab3 port-forward svc/jaeger 16686:16686 &
```

Abre http://localhost:8080, pide un taxi (botón "Call a car"), y luego busca la
traza en http://localhost:16686.

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns obs-lab3
```
