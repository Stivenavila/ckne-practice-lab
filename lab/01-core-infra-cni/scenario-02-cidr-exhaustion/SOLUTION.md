# Solución de referencia (versión reproducida en kind)

```bash
NS=net-lab2
kubectl -n $NS get pods -o wide | grep Pending
kubectl -n $NS describe pod <un-pod-pending>
# Events: 0/1 nodes are available: 1 Insufficient cpu.

kubectl describe node ckne-worker2 | grep -A5 "Allocated resources"

# Mitigación: reducir réplicas a lo que el nodo soporta, o quitar el nodeSelector
# para permitir que el scheduler use otros nodos.
kubectl -n $NS scale deployment web --replicas=6
# o bien:
kubectl -n $NS patch deployment web --type=json \
  -p '[{"op":"remove","path":"/spec/template/spec/nodeSelector"}]'
```

## Caso real: podCIDR agotado (no reproducible 1:1 en kind)

```bash
kubectl describe pod <pod-pending>
# Warning  FailedScheduling  no available IP addresses in range 10.244.4.0/26

kubectl describe node node-4 | grep -A2 PodCIDR
# podCIDR muy pequeño (/26 = 62 IPs) para la densidad de pods deseada

# Mitigación inmediata: sacar el nodo de scheduling mientras se corrige
kubectl cordon node-4

# Corrección real (requiere planificar, no es "hot patch"):
# - Ajustar --node-cidr-mask-size en el controller-manager (ej. de /26 a /24)
# - O aumentar el rango total del clúster (--cluster-cidr) — normalmente
#   implica recrear el clúster o los nodos afectados.
```
