# Scenario: TLS for a Gateway with cert-manager

**Namespace:** `sec-lab2`

## Prerequisite (one time per cluster)
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
kubectl -n cert-manager rollout status deployment/cert-manager --timeout=120s
kubectl -n cert-manager rollout status deployment/cert-manager-webhook --timeout=120s
```

## Context
Checkout's public Gateway still serves plaintext traffic and needs to
terminate TLS with a managed certificate (in this lab, a self-signed
`ClusterIssuer` — no real ACME since there's no public domain in the local
lab).

## Objective
1. Create a self-signed `ClusterIssuer`.
2. Create a `Certificate` for `checkout.lab.local` that produces the TLS
   Secret.
3. Reference that Secret in the Gateway's HTTPS listener.
4. Confirm with `openssl s_client`/`curl -k` that the Gateway now serves TLS.

## Definition of done
- [ ] The `Certificate` `checkout-tls` shows condition `Ready: True`
- [ ] The Gateway's HTTPS listener references the resulting TLS Secret (`certificateRefs`)

## Getting started
```bash
./setup.sh
```

## Verify
```bash
./verify.sh
```

## Cleanup
```bash
kubectl delete ns sec-lab2
kubectl delete clusterissuer selfsigned-issuer --ignore-not-found
```
