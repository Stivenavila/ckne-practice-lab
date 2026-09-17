# Setup del laboratorio CKNE

Requisitos en tu máquina: `docker`, `kind`, `kubectl`, `helm`, `cilium` CLI.

## 1. Crear el clúster (sin CNI ni kube-proxy)

```bash
kind create cluster --name ckne --config kind-config.yaml
kubectl get nodes
# Todos en NotReady: es esperado, no hay CNI todavía.
```

## 2. Instalar Cilium (reemplazando kube-proxy)

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install cilium cilium/cilium --version 1.16.5 \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=ckne-control-plane \
  --set k8sServicePort=6443 \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set encryption.enabled=false

cilium status --wait
kubectl get nodes   # ahora deben pasar a Ready
```

> `k8sServiceHost`/`k8sServicePort` deben apuntar al endpoint real del API server.
> Comprueba con: `kubectl cluster-info | head -1`

## 3. Cargar la imagen toolbox en el clúster

Antes de usar los escenarios, construye la imagen del toolbox (ver `../../toolbox/`) y cárgala en kind:

```bash
cd ../../toolbox
docker build -t ckne-toolbox:latest .
kind load docker-image ckne-toolbox:latest --name ckne
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
