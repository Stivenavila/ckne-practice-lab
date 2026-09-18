# ckne-toolbox

Imagen Docker de depuración de red para usar dentro del clúster mientras resuelves
los escenarios de [`../lab/`](../lab/) — el equivalente a `nicolaka/netshoot` pero
con las herramientas específicas que pide el temario de CKNE, incluyendo los CLIs
de `cilium` y `hubble`.

## Qué incluye

| Categoría | Herramientas |
|---|---|
| L2/L3 y rutas | `ip`, `ping`, `traceroute` |
| Captura de paquetes | `tcpdump`, `tshark` |
| NAT / filtrado | `iptables`, `nftables`, `ipset`, `conntrack` |
| DNS | `dig`, `host`, `nslookup` |
| HTTP / L7 | `curl`, `wget`, `nc`, `socat` |
| Rendimiento | `iperf3`, `mtr` |
| Kubernetes / Cilium | `kubectl`, `cilium`, `hubble` |
| Utilidades | `jq`, `openssl`, `ethtool`, `net-tools` |

## Construir y cargar en tu clúster (kind o minikube)

```bash
./build.sh <nombre-del-clúster>   # por defecto: ckne
```

Esto hace `docker build` de la imagen `ckne-toolbox:latest` y detecta automáticamente
si tu clúster es `kind` (usa `kind load docker-image`) o `minikube` (usa
`minikube image load`) — no necesitas subirla a ningún registry, ambas herramientas
la sirven localmente a los nodos.

> La imagen se construye para `linux/amd64`. Si tu host es ARM (Apple Silicon,
> Raspberry Pi), ajusta las URLs de `kubectl`/`cilium-cli`/`hubble-cli` en el
> `Dockerfile` a `arm64` antes de construir.

## Desplegar los pods de debug

```bash
kubectl apply -f debug-pod.yaml
kubectl get pods
```

Esto crea **dos pods**, para dos necesidades distintas:

| Pod | Red | Uso típico |
|---|---|---|
| `toolbox` | red normal del pod (namespace de red propio, capabilities `NET_ADMIN`/`NET_RAW`) | probar conectividad entre pods/Services, DNS, políticas de red desde la perspectiva de una carga de trabajo |
| `toolbox-hostnet` | `hostNetwork: true`, `privileged: true` | inspeccionar la red del **nodo**: `iptables -L`, `ip route`, capturar tráfico entre nodos con `tcpdump -i any` |

## Ejemplos de uso rápido

```bash
# Conectividad y DNS desde la perspectiva de un pod
kubectl exec -it toolbox -- curl -s http://mi-servicio.mi-namespace
kubectl exec -it toolbox -- dig mi-servicio.mi-namespace.svc.cluster.local

# Ver la tabla de rutas y reglas iptables del nodo
kubectl exec -it toolbox-hostnet -- ip route
kubectl exec -it toolbox-hostnet -- iptables -t nat -L -n -v

# Capturar tráfico entre nodos
kubectl exec -it toolbox-hostnet -- tcpdump -i any -n port 80

# Estado de Cilium y observabilidad
kubectl exec -it toolbox -- cilium status
kubectl exec -it toolbox -- hubble observe --namespace mi-namespace --verdict DROPPED
```

> **RBAC:** por defecto, `cilium status`/`hubble observe` ejecutados *dentro* del
> pod fallan con `forbidden` — el `ServiceAccount` `default` del namespace donde
> corre el toolbox no tiene permiso para leer `daemonsets`/`pods`/`configmaps` de
> `kube-system`. Para un clúster de estudio personal (no uses esto en un clúster
> compartido) puedes darle permisos amplios al SA que usa el toolbox:
> ```bash
> kubectl create clusterrolebinding toolbox-view \
>   --clusterrole=view --serviceaccount=default:default
> ```
> Alternativa sin tocar RBAC: corre `cilium`/`hubble` desde tu propia terminal
> (tu kubeconfig ya tiene permisos de admin) en vez de por `kubectl exec`; usa el
> pod solo para lo que sí necesita estar *dentro* del clúster: `curl`, `dig`,
> `tcpdump`, `iptables`, rutas.

## Limpieza

```bash
kubectl delete -f debug-pod.yaml
```
