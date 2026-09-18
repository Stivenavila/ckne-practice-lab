# Scenario: L3/L4 egress restricted to a single external CIDR

**Namespace:** `sec-lab6`

## Context
A `client` pod currently has unrestricted egress to the internet. Security
wants it locked down to reach **only** a specific external IP on a specific
port — pure L3/L4 (IP + port), no domain names and no HTTP/L7 inspection
involved. This is the plain network-policy control every CNI supports, as
opposed to Cilium's more advanced `toFQDNs`/L7 features used elsewhere in
this lab.

## Objective
Create a `CiliumNetworkPolicy` egress rule using `toCIDR` that allows
`client` to reach only `1.1.1.1/32` on port `443`, and blocks every other
external destination — purely by IP/CIDR and port.

## Definition of done
- [ ] A raw TCP connection from `client` to `1.1.1.1:443` succeeds
- [ ] A raw TCP connection from `client` to `8.8.8.8:443` (a different,
      equally real external IP) is blocked/times out

## Getting started

```bash
./setup.sh
kubectl -n sec-lab6 exec deploy/client -- nc -zv -w3 1.1.1.1 443   # works today
kubectl -n sec-lab6 exec deploy/client -- nc -zv -w3 8.8.8.8 443   # also works today — shouldn't, per policy
```

## Verify

```bash
./verify.sh
```

## Cleanup

```bash
kubectl delete ns sec-lab6
```
