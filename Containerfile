FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt update && apt upgrade -y \
  # install ip tools
  && apt install -y --no-install-recommends --no-install-suggests iproute2 \
  # install tinc
  && apt install -y --no-install-recommends --no-install-suggests tinc \
  # install setcap to allow binding privileged ports as non-root
  && apt install -y --no-install-recommends --no-install-suggests libcap2-bin \
  # clean up apt lists not covered by cache mounts
  && rm -rf /tmp/* /var/tmp/*

ARG ThisClientName="podman"
ENV ThisClientName=$ThisClientName
ARG ThisClientAddress="podman.dyndns.tld"
ENV ThisClientAddress=$ThisClientAddress
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
RUN echo "Name = $ThisClientName\nDevice = /dev/net/tun\nInterface = VPN\n#DeviceType = tap\nMode = router" > /etc/tinc/$VPNName/tinc.conf && \
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

# copy existing keys/config if present, otherwise generate new certificates
COPY --chown=tinc:tinc ./$VPNName/ /tmp/tinc-existing/
RUN if [ -f "/tmp/tinc-existing/rsa_key.priv" ]; then \
    cp /tmp/tinc-existing/rsa_key.priv "/etc/tinc/$VPNName/rsa_key.priv"; \
    [ -f "/tmp/tinc-existing/tinc.conf" ] && cp /tmp/tinc-existing/tinc.conf "/etc/tinc/$VPNName/tinc.conf"; \
    [ -f "/tmp/tinc-existing/hosts/$ThisClientName" ] && cp "/tmp/tinc-existing/hosts/$ThisClientName" "/etc/tinc/$VPNName/hosts/$ThisClientName"; \
    [ -f "/tmp/tinc-existing/tinc-up" ] && cp /tmp/tinc-existing/tinc-up "/etc/tinc/$VPNName/tinc-up" && chmod 750 "/etc/tinc/$VPNName/tinc-up" && chown tinc:tinc "/etc/tinc/$VPNName/tinc-up"; \
    [ -f "/tmp/tinc-existing/tinc-down" ] && cp /tmp/tinc-existing/tinc-down "/etc/tinc/$VPNName/tinc-down" && chmod 750 "/etc/tinc/$VPNName/tinc-down" && chown tinc:tinc "/etc/tinc/$VPNName/tinc-down"; \
  else \
    tincd -n "$VPNName" -K4096; \
  fi \
  && if [ -d "/tmp/tinc-existing/hosts" ]; then \
    for f in /tmp/tinc-existing/hosts/*; do \
      [ "$(basename '$f')" != "$ThisClientName" ] && cp "$f" "/etc/tinc/$VPNName/hosts/"; \
    done; \
  fi \
  && rm -rf /tmp/tinc-existing \
  && chown tinc:tinc "/etc/tinc/$VPNName/rsa_key.priv" "/etc/tinc/$VPNName/tinc.conf" "/etc/tinc/$VPNName/hosts/$ThisClientName"  "/etc/tinc/$VPNName/hosts/*" \
  && chmod 600 "/etc/tinc/$VPNName/rsa_key.priv" \
  && chmod 640 "/etc/tinc/$VPNName/tinc.conf" \
  && cat "/etc/tinc/$VPNName/hosts/$ThisClientName"

# allow tincd to bind to port 655 (<1024) and manage the tun device as non-root
RUN setcap cap_net_bind_service,cap_net_admin+ep /usr/sbin/tincd

USER tinc

EXPOSE 655/tcp 655/udp

CMD ["sh", "-c", "exec tincd -n \"$VPNName\" --pidfile=/run/tinc/tinc.$VPNName.pid --debug=3 -D"]
