```bash
cat <<EOF | kubectl apply -f -
apiVersion: cilium.io/v2
kind: CiliumEgressGatewayPolicy
metadata:
  name: egress-lab1
spec:
  selectors:
  - podSelector:
      matchLabels: {}
      namespaceSelector:
        matchLabels:
          name: traffic-lab1
  destinationCIDRs: ["0.0.0.0/0"]
  egressGateway:
    nodeSelector:
      matchLabels: {egress-node: "true"}
    # egressIP: <IP-estática-si-usas-una-interfaz-secundaria-dedicada>
    # si no defines egressIP, Cilium usa la IP primaria del nodo seleccionado.
EOF

kubectl get ciliumegressgatewaypolicy egress-lab1
CILIUM_POD=$(kubectl -n kube-system get pods -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl -n kube-system exec "$CILIUM_POD" -c cilium-agent -- cilium bpf egress list

kubectl -n traffic-lab1 exec deploy/client -- curl -s ifconfig.me
```
