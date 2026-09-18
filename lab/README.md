# CKNE Practical Lab

24 **real** scenarios (not simulated), organized across the 5 exam domains,
meant to run against a `kind` cluster with Cilium. Each one breaks something for
real — a misconfigured policy, a missing route, a broken selector — and forces
you to diagnose and fix it with real `kubectl`/`cilium`/`hubble`, matching the
exam's format.

## 0. Before you start

1. Check the requirements and quickstart in the [root README](../README.md).
2. Spin up the cluster and install Cilium following **[`00-setup/README.md`](00-setup/README.md)**.
3. Build and load the debugging toolbox: **[`../toolbox/`](../toolbox/)**.

Several scenarios need a Cilium feature enabled beyond the base setup (Gateway
API, egress gateway, Hubble metrics). Each scenario's `README.md` flags this in
a "Prerequisite" section with the exact `helm upgrade` command — you only need
to run it once per cluster, not per scenario.

## 1. Flow for each scenario

```bash
cd lab/<domain>/<scenario>
cat README.md          # context + objective + "Definition of done", no spoilers
./setup.sh               # breaks something real in the cluster
# ... diagnose and fix with real commands (kubectl, cilium, hubble, tcpdump...) ...
./verify.sh              # automatically confirms whether it's resolved
cat SOLUTION.md           # only if you get stuck, or to compare your approach at the end
```

Every scenario's `README.md` has a **"Definition of done"** checklist right
after the objective — that's the exact, concrete condition `verify.sh` checks.
If you're not sure whether you're finished, that checklist is the answer;
`verify.sh` is just the automated version of it.

Recommendations:
- **Time each scenario** — the exam is timed (~2h total, ~90-120 min split
  across several tasks).
- Don't open `SOLUTION.md` before attempting it — it drops the practice value to
  zero.
- If `verify.sh` fails, re-read the `README.md`: the key hint is almost always
  already in the context.
- When you finish a scenario, clean it up (command at the end of each
  `README.md`) before moving to the next one, so you don't carry resources over
  between scenarios.

## 2. Full scenario table

| # | Domain | Scenario | One-line objective | Extra requirement |
|---|---|---|---|---|
| 1 | Core Infra/CNI (15%) | [`scenario-01-missing-route`](01-core-infra-cni/scenario-01-missing-route/) | Restore a deleted route between nodes that breaks cross-node pod-to-pod connectivity | — |
| 2 | Core Infra/CNI | [`scenario-02-cidr-exhaustion`](01-core-infra-cni/scenario-02-cidr-exhaustion/) | Diagnose `Pending` pods due to node capacity and mitigate without deleting the Deployment | — |
| 3 | Core Infra/CNI | [`scenario-03-multus-secondary-iface`](01-core-infra-cni/scenario-03-multus-secondary-iface/) | Install Multus and give a pod a second network interface | — |
| 4 | Core Infra/CNI | [`scenario-04-nat-masquerade`](01-core-infra-cni/scenario-04-nat-masquerade/) | Restore a broken outbound MASQUERADE rule on a node using iptables/tcpdump | — |
| 5 | Service Networking/DNS (25%) | [`scenario-01-broken-selector`](02-service-networking-dns/scenario-01-broken-selector/) | Fix a Service with no endpoints due to a misspelled selector | — |
| 6 | Service Networking/DNS | [`scenario-02-coredns-stub-domain`](02-service-networking-dns/scenario-02-coredns-stub-domain/) | Add a stub domain in CoreDNS to forward an internal domain | — |
| 7 | Service Networking/DNS | [`scenario-03-headless-service`](02-service-networking-dns/scenario-03-headless-service/) | Turn a Service into headless to address StatefulSet pods individually via DNS | — |
| 8 | Service Networking/DNS | [`scenario-04-endpoint-not-ready`](02-service-networking-dns/scenario-04-endpoint-not-ready/) | Fix a readiness probe that leaves all pods out of the load balancing pool | — |
| 9 | Service Networking/DNS | [`scenario-05-gateway-httproute`](02-service-networking-dns/scenario-05-gateway-httproute/) | Expose a Service by creating an HTTPRoute on an existing Gateway | Gateway API enabled |
| 10 | Service Networking/DNS | [`scenario-06-kubeproxy-replacement-audit`](02-service-networking-dns/scenario-06-kubeproxy-replacement-audit/) | Find and remove a leftover kube-proxy DaemonSet that shouldn't be running alongside Cilium's replacement mode | — |
| 11 | Advanced Traffic (20%) | [`scenario-01-egress-gateway`](03-advanced-traffic/scenario-01-egress-gateway/) | Force a namespace's egress through a fixed node/IP with CiliumEgressGatewayPolicy | Egress Gateway enabled |
| 12 | Advanced Traffic | [`scenario-02-session-affinity-streaming`](03-advanced-traffic/scenario-02-session-affinity-streaming/) | Pin streaming connections to the same backend pod with sessionAffinity | — |
| 13 | Advanced Traffic | [`scenario-03-path-based-routing`](03-advanced-traffic/scenario-03-path-based-routing/) | Route `/orders` and `/inventory` to different backends with a single HTTPRoute | Gateway API enabled |
| 14 | Advanced Traffic | [`scenario-04-canary-weighted-routing`](03-advanced-traffic/scenario-04-canary-weighted-routing/) | Split traffic 90/10 between two backend versions with a weighted HTTPRoute | Gateway API enabled |
| 15 | Network Security/Policy (25%) | [`scenario-01-default-deny`](04-network-security-policy/scenario-01-default-deny/) | Isolate a namespace with default-deny + explicit allow from a source namespace | — |
| 16 | Network Security/Policy | [`scenario-02-cert-manager-tls`](04-network-security-policy/scenario-02-cert-manager-tls/) | Issue a certificate with cert-manager and terminate it on a Gateway HTTPS listener | cert-manager installed, Gateway API enabled |
| 17 | Network Security/Policy | [`scenario-03-wireguard-encryption`](04-network-security-policy/scenario-03-wireguard-encryption/) | Enable transparent encryption (WireGuard) between nodes and confirm it with tcpdump | — |
| 18 | Network Security/Policy | [`scenario-04-l7-http-policy`](04-network-security-policy/scenario-04-l7-http-policy/) | Allow only `GET /public` with an L7 CiliumNetworkPolicy | — |
| 19 | Network Security/Policy | [`scenario-05-dns-egress-policy`](04-network-security-policy/scenario-05-dns-egress-policy/) | Restrict egress to a single external FQDN with `toFQDNs` | — |
| 20 | Network Security/Policy | [`scenario-06-l3-l4-egress-cidr`](04-network-security-policy/scenario-06-l3-l4-egress-cidr/) | Restrict egress to a single external IP/port with a pure L3/L4 `toCIDR` rule | — |
| 21 | Observability (15%) | [`scenario-01-hubble-drop-audit`](05-observability/scenario-01-hubble-drop-audit/) | Find with `hubble observe` which policy is blocking traffic | — |
| 22 | Observability | [`scenario-02-prometheus-topk-drops`](05-observability/scenario-02-prometheus-topk-drops/) | Identify the service with the most drops by reading Hubble metrics | Hubble metrics enabled |
| 23 | Observability | [`scenario-03-tracing-otel`](05-observability/scenario-03-tracing-otel/) | Find the network hop with the highest latency in a distributed trace (Jaeger HotROD demo) | — |
| 24 | Observability | [`scenario-04-flow-log-audit`](05-observability/scenario-04-flow-log-audit/) | Audit a drop using `cilium monitor`'s raw eBPF event log instead of Hubble | — |

## 3. Per-domain prerequisites (one-time helm upgrades)

Some scenarios need a Cilium feature turned on beyond the base setup. Run these
**before** you reach those scenarios (each one can be applied at any time,
they won't break what's already installed):

```bash
# Gateway API (scenarios 9, 13, 14, 16)
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set standaloneDnsProxy.enabled=false \
  --set gatewayAPI.enabled=true
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/experimental-install.yaml
# (experimental channel, not standard — Cilium's operator checks for the
# TLSRoute CRD even if you never use it, and it's only in this channel)
kubectl -n kube-system rollout restart deployment/cilium-operator

# Egress Gateway (scenario 11)
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set standaloneDnsProxy.enabled=false \
  --set egressGateway.enabled=true
kubectl -n kube-system rollout restart daemonset/cilium

# cert-manager (scenario 16)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl -n cert-manager rollout status deployment/cert-manager --timeout=120s
kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=120s

# Hubble metrics (scenario 22)
helm upgrade cilium cilium/cilium --namespace kube-system --reuse-values \
  --set standaloneDnsProxy.enabled=false \
  --set hubble.metrics.enabled="{drop,tcp,flow}" \
  --set hubble.metrics.enableOpenMetrics=true
kubectl -n kube-system rollout restart daemonset/cilium
```

## 4. Common troubleshooting

**`cilium status` hangs or reports `unreachable`**
Check that `k8sServiceHost`/`k8sServicePort` in the Cilium install point to the
real API server endpoint: `kubectl cluster-info | head -1`.

**A scenario can't find the image (`ErrImagePull`/`ImagePullBackOff`)**
Public images (`nicolaka/netshoot`, `hashicorp/http-echo`, etc.) get pulled from
Docker Hub on first use — if your kind nodes don't have internet access, they
won't be able to resolve the pull. The toolbox (`ckne-toolbox`) needs to be
loaded manually with `kind load docker-image`/`minikube image load` (see
`toolbox/README.md`).

**`kubectl exec` into a Deployment fails with "no pods found"**
The pod may take a few seconds to reach `Running`. Every `setup.sh` already
waits with `kubectl wait`, but if you interrupted it, run
`kubectl get pods -n <ns> -w` to confirm the state before retrying.

**A Gateway is stuck with no IP in `status.addresses`, or `GatewayClass` shows `ACCEPTED: Unknown`**
Two separate things can cause this, found by actually testing this lab end to
end:
1. **Missing CRD**: Cilium's operator requires the `TLSRoute` CRD to exist
   even if you never use it — the `standard-install.yaml` Gateway API channel
   doesn't include it, only `experimental-install.yaml` does (all scenario
   READMEs in this lab already point at the experimental channel for this
   reason). Check `kubectl -n kube-system logs -l name=cilium-operator | grep gateway-api` —
   a "Required GatewayAPI resources are not found" error confirms this.
2. **No LoadBalancer implementation**: on a bare `kind`/`minikube` cluster
   there's no cloud LoadBalancer, so the `LoadBalancer` Service Cilium
   creates for each Gateway (`cilium-gateway-<name>`) never gets an
   `EXTERNAL-IP` — it stays `<pending>` forever, and so does the Gateway's
   `status.addresses`. Cilium's built-in L2 announcements feature (no
   MetalLB needed) can fix this — see the "Prerequisite" section of
   `03-advanced-traffic/scenario-04-canary-weighted-routing/README.md` for
   the exact commands. Even then, live Gateway dataplane traffic was
   unreliable in testing on this Cilium/Kubernetes version combo (Cilium's
   own socket-layer datapath rejected connections to the Gateway Service
   outright — `curl: (7) ... Operation not permitted`, immediately, from
   both pods and the node itself). If you hit this, don't burn hours on it:
   verify the **configuration** (HTTPRoute/Gateway resources, weights,
   paths) instead of insisting on live traffic — that's what this lab's
   affected scenarios (`gateway-httproute`, `path-based-routing`,
   `cert-manager-tls`, `canary-weighted-routing`) actually grade you on.
   This is a `kind`-specific rough edge, not something you'll hit on the
   exam's real infrastructure.
`kubectl -n kube-system rollout restart deployment/cilium-operator` after
fixing either cause is usually needed to pick it up.

**`hubble observe` shows nothing**
You need the relay running and reachable: `cilium hubble port-forward &` in
another terminal before using the CLI.

**I want to restart a scenario from scratch**
Delete its namespace (command at the end of each `README.md`) and run
`setup.sh` again — every script is idempotent (uses `kubectl apply`, doesn't
fail if the namespace already exists).

## 5. Checking your overall progress

Instead of manually tracking which of the 19 scenarios you've solved, run:

```bash
./check-progress.sh
```

It goes through every scenario, checks whether its namespace exists (i.e.
whether you attempted it), and if so re-runs its `verify.sh` — printing a
grouped report: `SOLVED` / `not yet — <reason>` / `not started`. Safe to run
anytime, doesn't change any cluster state.

## 6. Full lab cleanup

```bash
kind delete cluster --name ckne
# or, if you used minikube:
minikube delete -p ckne
```
