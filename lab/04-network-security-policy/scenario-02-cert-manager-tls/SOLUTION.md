```bash
NS=sec-lab2

cat <<YAML | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata: {name: selfsigned-issuer}
spec:
  selfSigned: {}
YAML

cat <<YAML | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata: {name: checkout-tls, namespace: $NS}
spec:
  secretName: checkout-tls-secret
  dnsNames: [checkout.lab.local]
  issuerRef: {name: selfsigned-issuer, kind: ClusterIssuer}
YAML

kubectl -n $NS get certificate checkout-tls

kubectl -n $NS patch gateway main-gateway --type=json -p '[{
  "op": "add",
  "path": "/spec/listeners/-",
  "value": {
    "name": "https",
    "protocol": "HTTPS",
    "port": 443,
    "tls": {"mode": "Terminate", "certificateRefs": [{"name": "checkout-tls-secret"}]}
  }
}]'

GW_IP=$(kubectl -n $NS get gateway main-gateway -o jsonpath='{.status.addresses[0].value}')
curl -k -v "https://$GW_IP" --resolve checkout.lab.local:443:$GW_IP
```
