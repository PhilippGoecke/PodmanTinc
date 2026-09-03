FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt upgrade -y \
  # install ip tools
  && apt install -y --no-install-recommends iproute2 \
  # install tinc
  && apt install -y --no-install-recommends tinc \

ARG ThisClientName="podman"
ARG ThisClientAddress="podman.dyndns.tld"
ENV VPNName="yourtincvpnname"
ARG VPNPeers="remotetincname1 remotetincname2"
ARG VPNSubnet="10.11.21.0/24"
ARG ThisClientUniqueVpnIp="10.11.21.42"

RUN groupadd -r tinc && useradd -r -g tinc tinc

RUN mkdir "/etc/tinc/$VPNName" \
  && mkdir "/etc/tinc/$VPNName/tinc"

COPY ./hosts/* "/etc/tinc/$VPNName/hosts/"
RUN echo "Name = $ThisClientName\nDevice = /dev/net/tun\nInterface = VPN\nDeviceType = tap\nMode = router" > /etc/tinc/$VPNName/tinc.conf && \
  for peer in $VPNPeers; do \
    echo "ConnectTo = $peer" >> /etc/tinc/$VPNName/tinc.conf; \
  done
RUN chown -R tinc:tinc /etc/tinc/$VPNName && chmod 700 /etc/tinc/$VPNName && chmod 640 /etc/tinc/$VPNName/tinc.conf \
  && echo "Address = $ThisClientAddress\nPort = 655\nTCPonly = yes\nSubnet = $ThisClientUniqueVpnIp/32" > "/etc/tinc/$VPNName/hosts/$ThisClientName" \
  && echo "#!/bin/sh\nip link set \$INTERFACE up\nip addr add $ThisClientUniqueVpnIp/32 dev \$INTERFACE\nip route add $VPNSubnet dev \$INTERFACE" > "/etc/tinc/$VPNName/tinc-up" \
  && chmod +x "/etc/tinc/$VPNName/tinc-up" \
  && echo "#!/bin/sh\nip route del $VPNSubnet dev \$INTERFACE\nip addr del $ThisClientUniqueVpnIp/32 dev \$INTERFACE\nip link set \$INTERFACE down" > "/etc/tinc/$VPNName/tinc-down" \
  && chmod +x "/etc/tinc/$VPNName/tinc-down"

RUN tincd -n "$VPNName" -K4096 \
  && cat "/etc/tinc/$VPNName/hosts/$ThisClientName"

EXPOSE 655/udp

USER tinc

CMD tincd -n "$VPNName" --debug=3 -D
