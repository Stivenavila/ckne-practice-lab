# ckne-toolbox: network debugging image for CKNE practice
# Includes the L2-L7 tools the exam expects you to master from inside a pod.
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    # L2/L3 and routing
    iproute2 iputils-ping traceroute \
    # packet capture and analysis
    tcpdump tshark \
    # NAT / filtering
    iptables ipset conntrack nftables \
    # DNS
    dnsutils bind9-host \
    # HTTP / L7
    curl wget netcat-openbsd socat \
    # performance and multipath
    iperf3 mtr-tiny \
    # general utilities
    jq less vim-tiny procps net-tools ethtool ca-certificates \
    openssl \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*

# kubectl (amd64 arch; adjust to arm64 if your host needs it)
RUN curl -fsSL -o /usr/local/bin/kubectl \
      "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x /usr/local/bin/kubectl

# cilium-cli (official binary from GitHub Releases)
RUN CILIUM_CLI_VERSION=$(curl -fsSL https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt) \
    && curl -fsSL -o /tmp/cilium.tar.gz \
      "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-amd64.tar.gz" \
    && tar xzvf /tmp/cilium.tar.gz -C /usr/local/bin \
    && rm -f /tmp/cilium.tar.gz

# hubble-cli (official binary from GitHub Releases)
RUN HUBBLE_VERSION=$(curl -fsSL https://raw.githubusercontent.com/cilium/hubble/master/stable.txt) \
    && curl -fsSL -o /tmp/hubble.tar.gz \
      "https://github.com/cilium/hubble/releases/download/${HUBBLE_VERSION}/hubble-linux-amd64.tar.gz" \
    && tar xzvf /tmp/hubble.tar.gz -C /usr/local/bin \
    && rm -f /tmp/hubble.tar.gz

WORKDIR /root
CMD ["sleep", "infinity"]
