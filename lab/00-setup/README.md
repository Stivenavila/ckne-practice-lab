# Setup del laboratorio CKNE

Requisitos en tu máquina: `docker`, `kind` **o** `minikube`, `kubectl`, `helm`,
`cilium` CLI, `hubble` CLI.

Elige una de las dos rutas para crear el clúster — el resto de la guía (Cilium,
toolbox, escenarios) es igual para ambas.

## 1a. Crear el clúster con kind (sin CNI ni kube-proxy)

```bash
kind create cluster --name ckne --config kind-config.yaml
kubectl get nodes
# Todos en NotReady: es esperado, no hay CNI todavía.
```

## 1b. Alternativa: crear el clúster con minikube

```bash
minikube start -p ckne --driver=docker --nodes=3 --cpus=2 --memory=3000mb \
  --network-plugin=cni --cni=false
kubectl get nodes
# Todos en NotReady: es esperado, no hay CNI todavía.
```

> minikube instala `kube-proxy` igual aunque pidas `--cni=false` (kind no). Lo
> quitamos manualmente en el paso 2 para que Cilium haga el reemplazo completo,
> igual que en kind.

## 2. Instalar Cilium (reemplazando kube-proxy)

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install cilium cilium/cilium --version 1.16.5 \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=<IP-o-nombre-del-control-plane> \
  --set k8sServicePort=<puerto-del-api-server> \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set hubble.metrics.enabled="{drop,tcp,flow}" \
  --set hubble.metrics.enableOpenMetrics=true \
  --set encryption.enabled=false

cilium status --wait
kubectl get nodes   # ahora deben pasar a Ready
```

> `k8sServiceHost`/`k8sServicePort` deben apuntar al endpoint real del API server.
> Comprueba con: `kubectl cluster-info | head -1` (con kind normalmente es
> `ckne-control-plane:6443`; con minikube, la IP que muestra `kubectl cluster-info`,
> por ejemplo `192.168.58.2:8443`).

**Solo si usaste minikube** (kind no instala kube-proxy cuando pides `--cni=false`,
así que este paso no aplica ahí):

```bash
kubectl -n kube-system delete daemonset kube-proxy
kubectl get nodes   # confirma que se mantienen Ready sin kube-proxy
```

## 3. Cargar la imagen toolbox en el clúster

Antes de usar los escenarios, construye la imagen del toolbox (ver `../../toolbox/`)
y cárgala en tu clúster — `build.sh` detecta automáticamente si es kind o minikube:

```bash
cd ../../toolbox
./build.sh ckne
kubectl apply -f debug-pod.yaml
```

## 4. Habilitar Hubble UI (usado en el dominio Observability)

```bash
cilium hubble ui
# abre http://localhost:12000
```

## 5. Cómo usar cada escenario

Cada carpeta `scenario-XX-*` contiene:
- `README.md`: contexto + objetivo (igual que en el examen: una tarea, no una pregunta).
- `setup.sh`: aplica los manifiestos (embebidos como heredoc) y **rompe** algo a propósito.
- `verify.sh`: valida si ya quedó resuelto (cuando aplica).
- `SOLUTION.md`: solución de referencia (revísala solo después de intentarlo).

Flujo recomendado:

```bash
cd lab/02-service-networking-dns/scenario-01-broken-selector
./setup.sh          # deja el entorno roto
# ... diagnostica y arregla usando kubectl real ...
./verify.sh          # (si existe) valida que quedó resuelto
```

Al terminar cada escenario, limpia con:

```bash
kubectl delete ns <namespace-del-escenario> --ignore-not-found
```
