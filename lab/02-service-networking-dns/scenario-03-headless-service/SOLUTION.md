```bash
kubectl -n svc-lab3 patch svc db -p '{"spec":{"clusterIP":"None"}}'
# If the patch fails because it's immutable, delete and recreate it:
kubectl -n svc-lab3 delete svc db
cat <<YAML | kubectl apply -f -
apiVersion: v1
kind: Service
metadata: {name: db, namespace: svc-lab3}
spec:
  clusterIP: None
  selector: {app: db}
  ports: [{port: 5432}]
YAML

kubectl run dnstest --rm -it --image=nicolaka/netshoot --restart=Never -- \
  dig +short db-0.db.svc-lab3.svc.cluster.local
```

**Note:** `clusterIP` is immutable once the Service is created; on the real
exam the correct fix is usually to recreate the resource, not hot-edit it.
