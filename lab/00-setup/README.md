# CKNE lab setup

Requirements on your machine: `docker`, `kind` **or** `minikube`, `kubectl`,
`helm`, `cilium` CLI, `hubble` CLI.

Pick one of the two paths to create the cluster — the rest of the guide
(Cilium, toolbox, scenarios) is the same for both.

## 1a. Create the cluster with kind (no CNI, no kube-proxy)

```bash
kind create cluster --name ckne --config kind-config.yaml
kubectl get nodes
# All NotReady: expected, no CNI yet.
```

## 1b. Alternative: create the cluster with minikube

```bash
minikube start -p ckne --driver=docker --nodes=3 --cpus=2 --memory=3000mb \
  --network-plugin=cni --cni=false
kubectl get nodes
# All NotReady: expected, no CNI yet.
```

> minikube installs `kube-proxy` anyway even when you ask for `--cni=false`
> (kind doesn't). We remove it manually in step 2 so Cilium does the full
> replacement, just like in kind.

## 2. Install Cilium (replacing kube-proxy)

```bash
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install cilium cilium/cilium --version 1.16.5 \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=<control-plane-IP-or-name> \
  --set k8sServicePort=<api-server-port> \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true \
  --set hubble.metrics.enabled="{drop,tcp,flow}" \
  --set hubble.metrics.enableOpenMetrics=true \
  --set encryption.enabled=false \
  --set socketLB.hostNamespaceOnly=true

cilium status --wait
kubectl get nodes   # should now be Ready
```

> `k8sServiceHost`/`k8sServicePort` must point at the real API server endpoint.
> Check with: `kubectl cluster-info | head -1` (with kind it's usually
> `ckne-control-plane:6443`; with minikube, the IP shown by
> `kubectl cluster-info`, e.g. `192.168.58.2:8443`).
>
> `socketLB.hostNamespaceOnly=true` matters more than it looks: without it,
> `sessionAffinity: ClientIP` on a Service silently makes it **unreachable**
> from other pods (Cilium's default socket-based load balancing doesn't
> correctly handle session affinity for pod-originated traffic — connections
> just time out). This restricts socket-LB to host-namespace traffic only,
> forcing pod traffic through the regular per-packet eBPF path, which does
> support it. Found and confirmed by actually toggling `sessionAffinity` on
> a real Service and watching it flip between reachable/unreachable while
> building `03-advanced-traffic/scenario-02-session-affinity-streaming`.

**Only if you used minikube** (kind doesn't install kube-proxy when you ask for
`--cni=false`, so this step doesn't apply there):

```bash
kubectl -n kube-system delete daemonset kube-proxy
kubectl get nodes   # confirms they stay Ready without kube-proxy
```

## 3. Load the toolbox image into the cluster

Before using the scenarios, build the toolbox image (see `../../toolbox/`) and
load it into your cluster — `build.sh` auto-detects whether it's kind or
minikube:

```bash
cd ../../toolbox
./build.sh ckne
kubectl apply -f debug-pod.yaml
```

## 4. Enable Hubble UI (used in the Observability domain)

```bash
cilium hubble ui
# opens http://localhost:12000
```

## 5. How to use each scenario

Each `scenario-XX-*` folder contains:
- `README.md`: context + objective (just like the exam: a task, not a question).
- `setup.sh`: applies the manifests (embedded as heredocs) and **breaks**
  something on purpose.
- `verify.sh`: checks whether it's already resolved (when applicable).
- `SOLUTION.md`: reference solution (only check it after you've attempted it).

Recommended flow:

```bash
cd lab/02-service-networking-dns/scenario-01-broken-selector
./setup.sh           # leaves the environment broken
# ... diagnose and fix using real kubectl ...
./verify.sh           # (if present) confirms it's resolved
```

When you finish each scenario, clean up with:

```bash
kubectl delete ns <scenario-namespace> --ignore-not-found
```
