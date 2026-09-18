```bash
NS=obs-lab4
# cilium monitor only sees local-node datapath events — target the agent on
# the same node as billing-client, not just any Cilium pod.
NODE=$(kubectl -n $NS get pod -l app=billing-client -o jsonpath='{.spec.nodeName}')
CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium --field-selector spec.nodeName=$NODE -o jsonpath='{.items[0].metadata.name}')

# Stream the drop log live (leave running in one terminal)
kubectl -n kube-system exec -it "$CILIUM_POD" -c cilium-agent -- cilium monitor --type drop &

# Generate the failing traffic in another terminal
kubectl -n $NS exec deploy/billing-client -- curl -s -m 3 ledger-svc
# the monitor output shows something like:
#   xx drop (Policy denied) flow ... to endpoint ..., identity ... -> ...

kubectl -n $NS get ciliumnetworkpolicy restrict-ledger -o yaml
# cause: ingress only allows from app=audited-caller, but billing-client has app=billing-client

kubectl -n $NS patch ciliumnetworkpolicy restrict-ledger --type=json -p \
  '[{"op":"replace","path":"/spec/ingress/0/fromEndpoints/0/matchLabels/app","value":"billing-client"}]'

kubectl -n $NS exec deploy/billing-client -- curl -s ledger-svc
```

**Exam note:** `cilium monitor` (or `cilium-dbg monitor` on newer versions)
taps directly into the BPF datapath's event stream — it works even without
Hubble deployed at all, which makes it the tool to reach for on a minimal
Cilium install or when Hubble relay itself is the thing that's broken.
