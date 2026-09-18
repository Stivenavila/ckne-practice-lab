#!/usr/bin/env bash
# Runs every scenario's verify.sh against whatever cluster your kubectl
# context currently points to, and prints a one-screen progress report.
#
# A scenario only gets checked if its namespace already exists (i.e. you ran
# its setup.sh at some point) — otherwise it's reported as "not started"
# instead of a false failure.
set -uo pipefail
cd "$(dirname "$0")"

if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "kubectl can't reach a cluster — is your context set? (kubectl config current-context)"
  exit 1
fi

declare -A SCENARIO_NS=(
  [01-core-infra-cni/scenario-01-missing-route]=net-lab1
  [01-core-infra-cni/scenario-02-cidr-exhaustion]=net-lab2
  [01-core-infra-cni/scenario-03-multus-secondary-iface]=net-lab3
  [02-service-networking-dns/scenario-01-broken-selector]=svc-lab1
  [02-service-networking-dns/scenario-02-coredns-stub-domain]=svc-lab2
  [02-service-networking-dns/scenario-03-headless-service]=svc-lab3
  [02-service-networking-dns/scenario-04-endpoint-not-ready]=svc-lab4
  [02-service-networking-dns/scenario-05-gateway-httproute]=svc-lab5
  [03-advanced-traffic/scenario-01-egress-gateway]=traffic-lab1
  [03-advanced-traffic/scenario-02-session-affinity-streaming]=traffic-lab2
  [03-advanced-traffic/scenario-03-path-based-routing]=traffic-lab3
  [04-network-security-policy/scenario-01-default-deny]=payments
  [04-network-security-policy/scenario-02-cert-manager-tls]=sec-lab2
  [04-network-security-policy/scenario-03-wireguard-encryption]=wg-lab
  [04-network-security-policy/scenario-04-l7-http-policy]=sec-lab4
  [04-network-security-policy/scenario-05-dns-egress-policy]=sec-lab5
  [05-observability/scenario-01-hubble-drop-audit]=obs-lab1
  [05-observability/scenario-02-prometheus-topk-drops]=obs-lab2
  [05-observability/scenario-03-tracing-otel]=obs-lab3
)

# Keep domain order matching the exam weight, not alphabetical.
ORDER=(
  "01-core-infra-cni/scenario-01-missing-route"
  "01-core-infra-cni/scenario-02-cidr-exhaustion"
  "01-core-infra-cni/scenario-03-multus-secondary-iface"
  "02-service-networking-dns/scenario-01-broken-selector"
  "02-service-networking-dns/scenario-02-coredns-stub-domain"
  "02-service-networking-dns/scenario-03-headless-service"
  "02-service-networking-dns/scenario-04-endpoint-not-ready"
  "02-service-networking-dns/scenario-05-gateway-httproute"
  "03-advanced-traffic/scenario-01-egress-gateway"
  "03-advanced-traffic/scenario-02-session-affinity-streaming"
  "03-advanced-traffic/scenario-03-path-based-routing"
  "04-network-security-policy/scenario-01-default-deny"
  "04-network-security-policy/scenario-02-cert-manager-tls"
  "04-network-security-policy/scenario-03-wireguard-encryption"
  "04-network-security-policy/scenario-04-l7-http-policy"
  "04-network-security-policy/scenario-05-dns-egress-policy"
  "05-observability/scenario-01-hubble-drop-audit"
  "05-observability/scenario-02-prometheus-topk-drops"
  "05-observability/scenario-03-tracing-otel"
)

pass=0; fail=0; skip=0
current_domain=""

for key in "${ORDER[@]}"; do
  domain="${key%%/*}"
  scenario="${key#*/}"
  ns="${SCENARIO_NS[$key]}"

  if [ "$domain" != "$current_domain" ]; then
    current_domain="$domain"
    echo ""
    echo "== ${domain} =="
  fi

  if ! kubectl get ns "$ns" >/dev/null 2>&1; then
    printf "  %-45s not started\n" "$scenario"
    skip=$((skip+1))
    continue
  fi

  if [ ! -x "$key/verify.sh" ]; then
    printf "  %-45s no verify.sh\n" "$scenario"
    continue
  fi

  if out=$(cd "$key" && ./verify.sh 2>&1); then
    printf "  %-45s SOLVED\n" "$scenario"
    pass=$((pass+1))
  else
    printf "  %-45s not yet — %s\n" "$scenario" "$(echo "$out" | tail -1)"
    fail=$((fail+1))
  fi
done

echo ""
echo "----------------------------------------"
echo "Solved: $pass   Not yet: $fail   Not started: $skip   (total: 19)"
