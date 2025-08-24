FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y \
  # install ip tools
  && apt install -y --no-install-recommends iproute2 \
  # install tinc
  && apt install -y --no-install-recommends tinc \
  # make image smaller
  && rm -rf "/var/lib/apt/lists/*" \
  && rm -rf /var/cache/apt/archives

ARG ThisClientName="podman"
ENV VPNName="yourtincvpnname"

RUN mkdir "/etc/tinc/$VPNName" \
  && mkdir "/etc/tinc/$VPNName/tinc"

COPY ./hosts/* "/etc/tinc/$VPNName/hosts/"
RUN echo "Name = $ThisClientName\nConnectTo = server1\nDevice = /dev/net/tun\nInterface = VPN\nDeviceType = tap\nMode = switch" > /etc/tinc/$VPNName/tinc.conf 
RUN chmod 640 /etc/tinc/$VPNName/tinc.conf \
 && echo "#Address = externalDNS\nPort = 655\nTCPonly = yes\nSubnet = 10.0.0.42/32" > "/etc/tinc/$VPNName/hosts/$ThisClientName"

RUN echo "#!/bin/sh\nip link set \$INTERFACE up\nip addr add 10.0.0.42/32 dev \$INTERFACE\nip route add 10.0.0.0/24 dev \$INTERFACE" > "/etc/tinc/$VPNName/tinc-up" \
 && chmod +x "/etc/tinc/$VPNName/tinc-up" \
 && echo "#!/bin/sh\nip route del 10.0.0.0/24 dev \$INTERFACE\nip addr del 10.0.0.42/32 dev \$INTERFACE\nip link set \$INTERFACE down" > "/etc/tinc/$VPNName/tinc-down" \
 && chmod +x "/etc/tinc/$VPNName/tinc-down"

RUN tincd -n "$VPNName" -K4096 \
  && cat "/etc/tinc/$VPNName/hosts/$ThisClientName"

CMD tincd -n "$VPNName" --debug=3 -D
