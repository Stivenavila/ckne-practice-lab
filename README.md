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
| [`lab/`](lab/) | 24 **real** scenarios against a `kind`/`minikube` + Cilium cluster | For serious practice that resembles the exam: breaking something real and fixing it |
| [`toolbox/`](toolbox/) | Network debugging Docker image (`ckne-toolbox`) | As a debug pod inside the cluster to diagnose any scenario |

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

## Quickstart (from zero to your first solved scenario)

```bash
git clone https://github.com/Stivenavila/ckne-practice-lab.git
cd ckne-practice-lab

# 1) Create the cluster WITHOUT a CNI or kube-proxy (just like the exam: you install the CNI by hand)
cd lab/00-setup
kind create cluster --name ckne --config kind-config.yaml
kubectl get nodes   # all NotReady, expected

# 2) Install Cilium replacing kube-proxy — follow lab/00-setup/README.md step by step
#    (it has the exact --set values depending on your API server)

# 3) Build and load the debugging toolbox into the cluster
cd ../../toolbox
./build.sh ckne
kubectl apply -f debug-pod.yaml
kubectl get pods   # toolbox and toolbox-hostnet should be Running

# 4) Solve your first scenario
cd ../lab/02-service-networking-dns/scenario-01-broken-selector
cat README.md        # read the context and objective (without peeking at the solution)
./setup.sh             # breaks something real in the cluster
#   ... diagnose with kubectl/cilium/hubble and fix it yourself ...
./verify.sh            # confirms whether it's resolved
```

Repeat the pattern `README.md` → `setup.sh` → diagnose → `verify.sh` with each
scenario. Only open `SOLUTION.md` if you get stuck or to compare your approach
once you're done — opening it beforehand ruins the practice value.

See **[`lab/README.md`](lab/README.md)** for the detailed flow, the full table of
the 24 scenarios, and common troubleshooting.

## Domains covered (official exam weight)

| Domain | Weight | Scenarios in `lab/` |
|---|---|---|
| Core Infrastructure and CNI | 15% | 4 |
| Service Networking and DNS | 25% | 6 |
| Advanced Traffic Management | 20% | 4 |
| Network Security and Policy | 25% | 6 |
| Observability | 15% | 4 |

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
