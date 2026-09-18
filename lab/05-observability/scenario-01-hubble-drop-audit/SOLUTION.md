```bash
cilium hubble port-forward &     # exposes hubble relay on localhost:4245

hubble observe --namespace obs-lab1 --verdict DROPPED
# TIMESTAMP  SRC:web-orders  DST:inventory  VERDICT: DROPPED  POLICY: deny-cross-app

kubectl -n obs-lab1 get networkpolicy deny-cross-app -o yaml
# cause: the "from" selector requires app=nonexistent-caller, which no real pod has

kubectl -n obs-lab1 delete networkpolicy deny-cross-app
# or, better, fix the selector to allow app=web-orders:
kubectl -n obs-lab1 patch networkpolicy deny-cross-app --type=json -p \
  '[{"op":"replace","path":"/spec/ingress/0/from/0/podSelector/matchLabels/app","value":"web-orders"}]'

kubectl -n obs-lab1 exec deploy/web-orders -- curl -s inventory-svc
```
