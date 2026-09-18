# Reference solution

```bash
NS=net-lab3

cat <<YAML | kubectl apply -f -
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
YAML

cat <<YAML | kubectl apply -f -
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
YAML

kubectl -n $NS exec capture-pod -- ip addr
# eth0  -> IP from the normal pod CIDR range (managed by Cilium)
# net1  -> 192.168.99.x       (second interface via Multus/bridge)
```

**Note:** if you use `macvlan` instead of `bridge`, in many Docker-in-Docker
(kind) environments it will fail because the host's `master` interface sits
behind Docker's bridge and doesn't allow nested macvlan mode. On the real exam
(bare-metal or VM nodes) `macvlan` is indeed the typical surgical choice for
dedicated high-performance interfaces.
