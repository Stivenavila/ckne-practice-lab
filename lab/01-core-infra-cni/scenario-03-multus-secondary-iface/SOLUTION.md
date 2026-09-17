# Solución de referencia

```bash
NS=net-lab3

cat <<EOF | kubectl apply -f -
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: bridge-fast
  namespace: $NS
spec:
  config: '{
    "cniVersion": "0.3.1",
    "type": "bridge",
    "bridge": "br-capture",
    "isGateway": true,
    "ipam": {
      "type": "host-local",
      "subnet": "192.168.99.0/24"
    }
  }'
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: capture-pod
  namespace: $NS
  labels: {app: capture}
  annotations:
    k8s.v1.cni.cncf.io/networks: bridge-fast
spec:
  containers:
  - name: capture
    image: nicolaka/netshoot
    command: ["sleep", "infinity"]
EOF

kubectl -n $NS exec capture-pod -- ip addr
# eth0  -> IP del rango del pod CIDR normal (gestionada por Cilium)
# net1  -> 192.168.99.x       (segunda interfaz vía Multus/bridge)
```

**Nota:** si usas `macvlan` en vez de `bridge`, en muchos entornos Docker-in-Docker
(kind) fallará porque el `master` interface del host está detrás del bridge de
Docker y no permite modo macvlan anidado. En el examen real (nodos bare-metal o VM)
`macvlan` sí es la opción típica quirúrgica para interfaces dedicadas de alto
rendimiento.
