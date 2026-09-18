# ckne-toolbox

Network debugging Docker image to use inside the cluster while you work through
the scenarios in [`../lab/`](../lab/) — the equivalent of `nicolaka/netshoot`
but with the specific tools the CKNE curriculum expects, including the
`cilium` and `hubble` CLIs.

## What's included

| Category | Tools |
|---|---|
| L2/L3 and routing | `ip`, `ping`, `traceroute` |
| Packet capture | `tcpdump`, `tshark` |
| NAT / filtering | `iptables`, `nftables`, `ipset`, `conntrack` |
| DNS | `dig`, `host`, `nslookup` |
| HTTP / L7 | `curl`, `wget`, `nc`, `socat` |
| Performance | `iperf3`, `mtr` |
| Kubernetes / Cilium | `kubectl`, `cilium`, `hubble` |
| Utilities | `jq`, `openssl`, `ethtool`, `net-tools` |

## Build and load into your cluster (kind or minikube)

```bash
./build.sh <cluster-name>   # defaults to: ckne
```

This runs `docker build` for the `ckne-toolbox:latest` image and automatically
detects whether your cluster is `kind` (uses `kind load docker-image`) or
`minikube` (uses `minikube image load`) — you don't need to push it to any
registry, both tools serve it locally.

> The image is built for `linux/amd64`. If your host is ARM (Apple Silicon,
> Raspberry Pi), adjust the `kubectl`/`cilium-cli`/`hubble-cli` URLs in the
> `Dockerfile` to `arm64` before building.

## Deploy the debug pods

```bash
kubectl apply -f debug-pod.yaml
kubectl get pods
```

This creates **two pods**, for two different needs:

| Pod | Network | Typical use |
|---|---|---|
| `toolbox` | normal pod network (own network namespace, `NET_ADMIN`/`NET_RAW` capabilities) | test connectivity between pods/Services, DNS, network policies from a workload's perspective |
| `toolbox-hostnet` | `hostNetwork: true`, `privileged: true` | inspect the **node's** network: `iptables -L`, `ip route`, capture traffic between nodes with `tcpdump -i any` |

## Quick usage examples

```bash
# Connectivity and DNS from a pod's perspective
kubectl exec -it toolbox -- curl -s http://my-service.my-namespace
kubectl exec -it toolbox -- dig my-service.my-namespace.svc.cluster.local

# Check the node's routing table and iptables rules
kubectl exec -it toolbox-hostnet -- ip route
kubectl exec -it toolbox-hostnet -- iptables -t nat -L -n -v

# Capture traffic between nodes
kubectl exec -it toolbox-hostnet -- tcpdump -i any -n port 80

# Cilium status and observability
kubectl exec -it toolbox -- cilium status
kubectl exec -it toolbox -- hubble observe --namespace my-namespace --verdict DROPPED
```

> **RBAC:** by default, `cilium status`/`hubble observe` run *inside* the pod
> fail with `forbidden` — the `default` ServiceAccount in the namespace where
> the toolbox runs doesn't have permission to read `daemonsets`/`pods`/
> `configmaps` in `kube-system`. For a personal study cluster (don't do this on
> a shared cluster) you can grant broad permissions to the ServiceAccount the
> toolbox uses:
> ```bash
> kubectl create clusterrolebinding toolbox-view \
>   --clusterrole=view --serviceaccount=default:default
> ```
> Alternative without touching RBAC: run `cilium`/`hubble` from your own
> terminal (your kubeconfig already has admin permissions) instead of via
> `kubectl exec`; use the pod only for what actually needs to run *inside* the
> cluster: `curl`, `dig`, `tcpdump`, `iptables`, routes.

## Cleanup

```bash
kubectl delete -f debug-pod.yaml
```
