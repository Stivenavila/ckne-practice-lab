# CKNE Practice Lab

Hands-on study material for the **CKNE (Certified Kubernetes Network Engineer)**
certification from CNCF/Linux Foundation. The exam is 100% practical (tasks on a
real cluster, not multiple-choice questions), so this whole repo is designed for
you to practice by solving real problems, not reading theory.

> Not official CNCF/Linux Foundation content — this is personal study material,
> built from the exam's public curriculum.

## What's here?

| Folder / file | What it is | When to use it |
|---|---|---|
| [`ckne-practice.html`](ckne-practice.html) | Browser terminal simulator, 20 scenarios with hints and solutions | To drill commands and diagnostic flow without needing a cluster (on the bus, without a powerful laptop, etc.) |
| [`lab/`](lab/) | 19 **real** scenarios against a `kind`/`minikube` + Cilium cluster | For serious practice that resembles the exam: breaking something real and fixing it |
| [`toolbox/`](toolbox/) | Network debugging Docker image (`ckne-toolbox`) | As a debug pod inside the cluster to diagnose any scenario |
| [`console/`](console/) | Local web UI: real terminal + current scenario's instructions side by side, with a "Verify" button | If you'd rather not juggle a separate terminal and README tab — same `lab/` workflow, nicer UI. Localhost-only, no cluster changes on its own |

Start with the simulator if you want a quick syntax refresher, and use `lab/` for
serious practice — the simulator doesn't replace running commands against a real
cluster.

## Requirements

You need these binaries installed on your machine (Linux/macOS):

| Tool | For | Install |
|---|---|---|
| `docker` | run the kind/minikube nodes and build the toolbox | https://docs.docker.com/engine/install/ |
| `kind` or `minikube` | create the local cluster | https://kind.sigs.k8s.io/docs/user/quick-start/#installation / https://minikube.sigs.k8s.io/docs/start/ |
| `kubectl` | talk to the cluster | https://kubernetes.io/docs/tasks/tools/#kubectl |
| `helm` | install Cilium | https://helm.sh/docs/intro/install/ |
| `cilium` (CLI) | install/verify Cilium, egress/hubble | https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli |
| `hubble` (CLI) | network observability (`hubble observe`) | https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/ |
| `jq` | parse JSON output in verification scripts | your distro's package manager |

Verify everything is available before you start:

```bash
for bin in docker kind kubectl helm cilium hubble jq; do
  command -v "$bin" >/dev/null 2>&1 && echo "OK  $bin" || echo "MISSING  $bin"
done
```

## Step-by-step: deploy the lab and run everything

### 1. Clone the repo

```bash
git clone https://github.com/Stivenavila/ckne-practice-lab.git
cd ckne-practice-lab
```

### 2. Create the cluster (pick one)

The cluster is created **without a CNI or kube-proxy** on purpose — just like
the real exam, you install the CNI by hand in the next step.

**Option A — kind:**
```bash
cd lab/00-setup
kind create cluster --name ckne --config kind-config.yaml
kubectl get nodes   # all NotReady, expected — no CNI yet
```

**Option B — minikube:**
```bash
cd lab/00-setup
minikube start -p ckne --driver=docker --nodes=3 --cpus=2 --memory=3000mb \
  --network-plugin=cni --cni=false
kubectl get nodes   # all NotReady, expected — no CNI yet
```

### 3. Install Cilium (replaces kube-proxy)

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
  --set hubble.metrics.enableOpenMetrics=true

cilium status --wait
kubectl get nodes   # should now be Ready
```

Find `k8sServiceHost`/`k8sServicePort` with `kubectl cluster-info | head -1`
(kind: usually `ckne-control-plane:6443`; minikube: the IP shown, e.g.
`192.168.58.2:8443`).

**Only if you used minikube**, kube-proxy gets installed anyway — remove it so
Cilium does the full replacement:
```bash
kubectl -n kube-system delete daemonset kube-proxy
kubectl get nodes   # confirms they stay Ready without kube-proxy
```

Full details and troubleshooting: **[`lab/00-setup/README.md`](lab/00-setup/README.md)**.

### 4. Build and load the debugging toolbox

```bash
cd ../../toolbox
./build.sh ckne          # auto-detects kind vs minikube, no registry needed
kubectl apply -f debug-pod.yaml
kubectl get pods          # toolbox and toolbox-hostnet should be Running
```

### 5. Solve your first scenario

```bash
cd ../lab/02-service-networking-dns/scenario-01-broken-selector
cat README.md        # read the context and objective (without peeking at the solution)
./setup.sh             # breaks something real in the cluster
#   ... diagnose with kubectl/cilium/hubble and fix it yourself ...
./verify.sh            # confirms whether it's resolved
```

Repeat the pattern `README.md` → `setup.sh` → diagnose → `verify.sh` with each
of the 19 scenarios. Only open `SOLUTION.md` if you get stuck or to compare
your approach once you're done — opening it beforehand ruins the practice
value.

See **[`lab/README.md`](lab/README.md)** for the full table of scenarios,
per-domain prerequisites (Gateway API, egress gateway, cert-manager, Hubble
metrics), and common troubleshooting.

## Running the demos

A few scenarios spin up real UIs you can open in your browser — worth trying
once your cluster is up, even outside of solving the scenario itself.

**Hubble UI** — live visual map of traffic flowing through the cluster:
```bash
cilium hubble ui
# opens http://localhost:12000
```

**Jaeger + HotROD tracing demo** (from `lab/05-observability/scenario-03-tracing-otel/`):
```bash
cd lab/05-observability/scenario-03-tracing-otel
./setup.sh
kubectl -n obs-lab3 port-forward svc/hotrod 8080:8080 &
kubectl -n obs-lab3 port-forward svc/jaeger 16686:16686 &
# open http://localhost:8080, click "Call a car", then inspect the trace at
# http://localhost:16686
```

**Terminal simulator's exam mode** — no cluster required, just open the file:
```bash
xdg-open ckne-practice.html   # or just double-click it
# click "Exam mode": 8 random tasks weighted by domain, one 90-minute timer,
# hints and solutions disabled until you finish
```

## Domains covered (official exam weight)

| Domain | Weight | Scenarios in `lab/` |
|---|---|---|
| Core Infrastructure and CNI | 15% | 3 |
| Service Networking and DNS | 25% | 5 |
| Advanced Traffic Management | 20% | 3 |
| Network Security and Policy | 25% | 5 |
| Observability | 15% | 3 |

## Cleanup

Each scenario has its own cleanup instructions in its `README.md`. To tear down
the whole lab and start fresh:

```bash
kind delete cluster --name ckne
# or, if you used minikube:
minikube delete -p ckne
```

## Repo structure

```
.
├── ckne-practice.html      # terminal simulator (standalone, no dependencies)
├── lab/                     # real lab, full README and scenario table here
│   ├── 00-setup/            # kind-config.yaml + Cilium install guide
│   ├── 01-core-infra-cni/
│   ├── 02-service-networking-dns/
│   ├── 03-advanced-traffic/
│   ├── 04-network-security-policy/
│   └── 05-observability/
└── toolbox/                 # network debugging Docker image + debug pod
```
