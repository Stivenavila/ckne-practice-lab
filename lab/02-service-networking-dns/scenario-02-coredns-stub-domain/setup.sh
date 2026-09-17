#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab2
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

# --- "DNS corporativo" simulado: un CoreDNS separado que sabe resolver corp.internal ---
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata: {name: corp-dns-config, namespace: $NS}
data:
  Corefile: |
    corp.internal:53 {
      file /etc/coredns/corp.internal.db
      log
    }
  corp.internal.db: |
    \$ORIGIN corp.internal.
    @   3600 IN SOA ns.corp.internal. admin.corp.internal. (1 7200 3600 1209600 3600)
    @   3600 IN NS  ns.corp.internal.
    app 3600 IN A   172.20.0.99
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: corp-dns, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: corp-dns}}
  template:
    metadata: {labels: {app: corp-dns}}
    spec:
      containers:
      - name: coredns
        image: coredns/coredns:1.11.3
        args: ["-conf", "/etc/coredns/Corefile"]
        volumeMounts:
        - {name: config, mountPath: /etc/coredns}
        ports: [{containerPort: 53, protocol: UDP}, {containerPort: 53, protocol: TCP}]
      volumes:
      - name: config
        configMap: {name: corp-dns-config}
---
apiVersion: v1
kind: Service
metadata: {name: corp-dns, namespace: $NS}
spec:
  selector: {app: corp-dns}
  ports:
  - {name: dns-udp, port: 53, protocol: UDP}
  - {name: dns-tcp, port: 53, protocol: TCP}
EOF

kubectl -n "$NS" wait --for=condition=Ready pod -l app=corp-dns --timeout=90s
CORP_DNS_IP=$(kubectl -n "$NS" get svc corp-dns -o jsonpath='{.spec.clusterIP}')

echo "DNS corporativo simulado desplegado en $NS."
echo "IP del ClusterIP: $CORP_DNS_IP  (apunta el forward de corp.internal aquí)"
echo ""
echo "Tarea: edita el ConfigMap coredns en kube-system y agrega un bloque:"
echo "  corp.internal:53 {"
echo "      forward . $CORP_DNS_IP"
echo "  }"
echo "Luego: kubectl -n kube-system rollout restart deployment coredns"
