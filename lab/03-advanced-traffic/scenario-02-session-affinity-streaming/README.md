# Escenario: conexiones que rotan de pod en un servicio "streaming"

**Namespace:** `traffic-lab2`

## Contexto
`llm-inference` responde con el nombre del pod que atendió la petición. El equipo
reporta que llamadas sucesivas de un mismo cliente terminan en pods distintos,
rompiendo sesiones largas (streaming).

## Objetivo
Confirma el comportamiento por defecto (round robin entre pods) y corrige el Service
para que las peticiones de un mismo cliente se mantengan pegadas al mismo pod.

## Empezar
```bash
./setup.sh
for i in 1 2 3 4; do
  kubectl -n traffic-lab2 exec deploy/client -- curl -s llm-inference
done
```

## Verificar
```bash
./verify.sh
```

## Limpieza
```bash
kubectl delete ns traffic-lab2
```
