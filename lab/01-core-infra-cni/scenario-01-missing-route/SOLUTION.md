# Solución de referencia

```bash
NS=net-lab1
kubectl -n $NS get pods -o wide
IP_A=$(kubectl -n $NS get pod -l app=web-a -o jsonpath='{.items[0].status.podIP}')
IP_B=$(kubectl -n $NS get pod -l app=web-b -o jsonpath='{.items[0].status.podIP}')

# El ping falla:
kubectl -n $NS exec deploy/web-a -- ping -c 2 $IP_B

# Diagnóstico: entra al nodo que hospeda a web-b y revisa su tabla de rutas
docker exec ckne-worker2 ip route
# Falta la ruta hacia el podCIDR del otro worker (ej. 10.244.1.0/24 vía la IP del CNI)

# Referencia: cuál es el podCIDR "roto"
kubectl get node ckne-worker -o jsonpath='{.spec.podCIDR}'

# Fix: restaurar la ruta (ajusta el "via" al gateway real que reporte "ip route" en el nodo bueno)
docker exec ckne-worker ip route   # copia el patrón de ruta válido de este nodo
docker exec ckne-worker2 ip route add <PODCIDR-WORKER1> via <GATEWAY-CNI-EN-WORKER2>

# Verifica
kubectl -n $NS exec deploy/web-a -- ping -c 2 $IP_B
```

**Nota de examen:** en un clúster real (no kind), esta ruta normalmente la gestiona
el propio CNI (Cilium programa las rutas vía BPF/eBPF o vía las tablas de rutas del
kernel dependiendo del modo: `tunnel` vxlan/geneve vs `native-routing`). Si ves este
síntoma en producción, antes de tocar rutas a mano revisa:

```bash
cilium status
cilium bpf tunnel list
kubectl -n kube-system logs ds/cilium -c cilium-agent | grep -i route
```
