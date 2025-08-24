podman build --no-cache --rm -f Containerfile -t tinc:demo .
podman run --interactive --tty --cap-add=NET_ADMIN --device /dev/net/tun --security-opt="label=disable" tinc:demo
