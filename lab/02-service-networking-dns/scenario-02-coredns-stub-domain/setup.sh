#!/usr/bin/env bash
set -euo pipefail
NS=svc-lab2
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

# --- Simulated "corporate DNS": a separate CoreDNS that knows how to resolve corp.internal ---
cat <<YAML | kubectl apply -f -
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
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=corp-dns --timeout=90s
CORP_DNS_IP=$(kubectl -n "$NS" get svc corp-dns -o jsonpath='{.spec.clusterIP}')

echo "Simulated corporate DNS deployed in $NS."
echo "ClusterIP: $CORP_DNS_IP  (point the corp.internal forward here)"
echo ""
echo "Task: edit the coredns ConfigMap in kube-system and add a block:"
echo "  corp.internal:53 {"
echo "      forward . $CORP_DNS_IP"
echo "  }"
echo "Then: kubectl -n kube-system rollout restart deployment coredns"
