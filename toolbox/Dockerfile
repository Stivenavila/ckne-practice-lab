# ckne-toolbox: imagen de depuración de red para practicar CKNE
# Incluye herramientas L2-L7 que el examen espera que domines desde dentro de un pod.
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    # L2/L3 y rutas
    iproute2 iputils-ping traceroute \
    # captura y análisis de paquetes
    tcpdump tshark \
    # NAT / filtrado
    iptables ipset conntrack nftables \
    # DNS
    dnsutils bind9-host \
    # HTTP / L7
    curl wget netcat-openbsd socat \
    # rendimiento y multipath
    iperf3 mtr-tiny \
    # utilidades generales
    jq less vim-tiny procps net-tools ethtool ca-certificates \
    openssl \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*

# kubectl (arquitectura amd64; ajusta a arm64 si tu host lo requiere)
RUN curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x /usr/local/bin/kubectl

# cilium-cli (binario oficial de GitHub Releases)
RUN CILIUM_CLI_VERSION=$(curl -fsSL https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt) \
    && curl -fsSL -o /tmp/cilium.tar.gz \
      "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz" \
    && tar xzvf /tmp/cilium.tar.gz -C /usr/local/bin \
    && rm -f /tmp/cilium.tar.gz

# hubble-cli (binario oficial de GitHub Releases)
RUN HUBBLE_VERSION=$(curl -fsSL https://raw.githubusercontent.com/cilium/hubble/master/stable.txt) \
    && curl -fsSL -o /tmp/hubble.tar.gz \
      "https://github.com/cilium/hubble/releases/download/${HUBBLE_VERSION}/hubble-linux-amd64.tar.gz" \
    && tar xzvf /tmp/hubble.tar.gz -C /usr/local/bin \
    && rm -f /tmp/hubble.tar.gz

WORKDIR /root
CMD ["sleep", "infinity"]
