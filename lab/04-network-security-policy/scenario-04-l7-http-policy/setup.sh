#!/usr/bin/env bash
set -euo pipefail
NS=sec-lab4
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata: {name: api-nginx-conf, namespace: $NS}
data:
  default.conf: |
    server {
      listen 80;
      location /public { return 200 "public-ok\n"; }
      location /admin  { return 200 "admin-ok\n"; }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: api, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: api}}
  template:
    metadata: {labels: {app: api}}
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports: [{containerPort: 80}]
        volumeMounts:
        - {name: conf, mountPath: /etc/nginx/conf.d}
      volumes:
      - name: conf
        configMap: {name: api-nginx-conf}
---
apiVersion: v1
kind: Service
metadata: {name: api-svc, namespace: $NS}
spec: {selector: {app: api}, ports: [{port: 80}]}
---
apiVersion: apps/v1
kind: Deployment
metadata: {name: client, namespace: $NS}
spec:
  replicas: 1
  selector: {matchLabels: {app: client}}
  template:
    metadata: {labels: {app: client}}
    spec: {containers: [{name: client, image: nicolaka/netshoot, command: ["sleep","infinity"]}]}
YAML

kubectl -n "$NS" wait --for=condition=Ready pod -l app=api --timeout=90s
kubectl -n "$NS" wait --for=condition=Ready pod -l app=client --timeout=90s
echo "Namespace: $NS ready. There's no CiliumNetworkPolicy yet — all L7 traffic passes."
