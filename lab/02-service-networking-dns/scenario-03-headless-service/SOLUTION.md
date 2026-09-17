```bash
kubectl -n svc-lab3 patch svc db -p '{"spec":{"clusterIP":"None"}}'
# Si el patch falla por ser inmutable, bórralo y recréalo:
kubectl -n svc-lab3 delete svc db
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata: {name: db, namespace: svc-lab3}
spec:
  clusterIP: None
  selector: {app: db}
  ports: [{port: 5432}]
EOF

kubectl run dnstest --rm -it --image=nicolaka/netshoot --restart=Never -- \
  dig +short db-0.db.svc-lab3.svc.cluster.local
```

**Nota:** `clusterIP` es inmutable una vez creado el Service; en el examen real la
forma correcta suele ser recrear el recurso, no editarlo en caliente.
