FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt upgrade -y \
  # install ip tools
  && apt install -y --no-install-recommends --no-install-suggests iproute2 \
  # install tinc
  && apt install -y --no-install-recommends --no-install-suggests tinc \
  # clean up apt lists not covered by cache mounts
  && rm -rf /tmp/* /var/tmp/*

ARG ThisClientName="podman"
ARG ThisClientAddress="podman.dyndns.tld"
ARG VPN_NETWORK="yourtincvpnname"
ENV VPNName=$VPN_NETWORK
ARG VPNPeers="remotetincname1 remotetincname2"
ARG VPNSubnet="10.11.21.0/24"
ARG ThisClientUniqueVpnIp="10.11.21.42"

RUN groupadd -r tinc && useradd -r -g tinc -s /usr/sbin/nologin -d /nonexistent tinc

RUN mkdir -p "/etc/tinc/$VPNName/hosts" \
  && mkdir -p /run/tinc \
  && chown tinc:tinc /run/tinc \
  && chmod 750 /run/tinc

COPY --chown=tinc:tinc ./hosts/* "/etc/tinc/$VPNName/hosts/"
RUN echo "Name = $ThisClientName\nDevice = /dev/net/tun\nInterface = VPN\nDeviceType = tap\nMode = router" > /etc/tinc/$VPNName/tinc.conf && \
  for peer in $VPNPeers; do \
    echo "ConnectTo = $peer" >> /etc/tinc/$VPNName/tinc.conf; \
  done
RUN chown -R tinc:tinc "/etc/tinc/$VPNName" \
  && chmod 700 "/etc/tinc/$VPNName" \
  && chmod 750 "/etc/tinc/$VPNName/hosts" \
  && chmod 640 "/etc/tinc/$VPNName/tinc.conf" \
  && echo "Address = $ThisClientAddress\nPort = 655\nTCPonly = yes\nSubnet = $ThisClientUniqueVpnIp/32" > "/etc/tinc/$VPNName/hosts/$ThisClientName" \
  && echo "#!/bin/sh\nip link set \$INTERFACE up\nip addr add $ThisClientUniqueVpnIp/32 dev \$INTERFACE\nip route add $VPNSubnet dev \$INTERFACE" > "/etc/tinc/$VPNName/tinc-up" \
  && chmod 750 "/etc/tinc/$VPNName/tinc-up" \
  && echo "#!/bin/sh\nip route del $VPNSubnet dev \$INTERFACE\nip addr del $ThisClientUniqueVpnIp/32 dev \$INTERFACE\nip link set \$INTERFACE down" > "/etc/tinc/$VPNName/tinc-down" \
  && chmod 750 "/etc/tinc/$VPNName/tinc-down" \
  && chown tinc:tinc "/etc/tinc/$VPNName/tinc-up" "/etc/tinc/$VPNName/tinc-down"

USER tinc
RUN tincd -n "$VPNName" -K4096 \
  && chmod 600 "/etc/tinc/$VPNName/rsa_key.priv" \
  && cat "/etc/tinc/$VPNName/hosts/$ThisClientName"

EXPOSE 655/udp

CMD ["sh", "-c", "exec tincd -n \"$VPNName\" --pidfile=/run/tinc/tinc.$VPNName.pid --debug=3 -D"]
