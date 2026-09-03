mkdir -p "$(pwd)/tinc_config"

podman build --no-cache --rm --volume $(pwd)/tinc_config/:/etc/tinc/ --build-arg VPN_NODE_DNS=name.dyndns.tld --file Containerfile --tag tinc:demo .
podman run --interactive --tty --env VPN_NODE_DNS=name.dyndns.tld --publish 655:655 --volume $(pwd)/tinc_config/:/etc/tinc/ --cap-add=NET_ADMIN --device --security-opt="label=disable" /dev/net/tun tinc:demo
