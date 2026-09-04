# Configuration
VPN_NODE_DNS="name.dyndns.tld"
THIS_CLIENT_NAME="podman"
THIS_CLIENT_ADDRESS="podman.dyndns.tld"
VPN_NETWORK="yourtincvpnname"
VPN_PEERS="remotetincname1 remotetincname2"
VPN_SUBNET="10.11.21.0/24"
THIS_CLIENT_UNIQUE_VPN_IP="10.11.21.42"
TINC_CONFIG_DIR="$(pwd)/tinc_config"
IMAGE_TAG="tinc:demo"

mkdir -p "$TINC_CONFIG_DIR"

podman build --no-cache --rm --volume "$TINC_CONFIG_DIR/":/etc/tinc/ --build-arg VPN_NODE_DNS="$VPN_NODE_DNS" --build-arg ThisClientName="$THIS_CLIENT_NAME" --build-arg ThisClientAddress="$THIS_CLIENT_ADDRESS" --build-arg VPN_NETWORK="$VPN_NETWORK" --build-arg VPNPeers="$VPN_PEERS" --build-arg VPNSubnet="$VPN_SUBNET" --build-arg ThisClientUniqueVpnIp="$THIS_CLIENT_UNIQUE_VPN_IP" --file Containerfile --tag "$IMAGE_TAG" .
#podman run --interactive --tty --env VPN_NODE_DNS="$VPN_NODE_DNS" --env ThisClientName="$THIS_CLIENT_NAME" --env ThisClientAddress="$THIS_CLIENT_ADDRESS" --env VPNName="$VPN_NETWORK" --env VPNPeers="$VPN_PEERS" --env VPNSubnet="$VPN_SUBNET" --env ThisClientUniqueVpnIp="$THIS_CLIENT_UNIQUE_VPN_IP" --publish 655:655 --volume "$TINC_CONFIG_DIR/":/etc/tinc/ --cap-add=NET_ADMIN --device /dev/net/tun --security-opt="label=disable" --security-opt=seccomp=unconfirmed --net=host "$IMAGE_TAG"
#podman run --interactive --tty --env VPN_NODE_DNS="$VPN_NODE_DNS" --env ThisClientName="$THIS_CLIENT_NAME" --env ThisClientAddress="$THIS_CLIENT_ADDRESS" --env VPNName="$VPN_NETWORK" --env VPNPeers="$VPN_PEERS" --env VPNSubnet="$VPN_SUBNET" --env ThisClientUniqueVpnIp="$THIS_CLIENT_UNIQUE_VPN_IP" --publish 655:655 --volume "$TINC_CONFIG_DIR/":/etc/tinc/ --cap-add=NET_ADMIN --device /dev/net/tun --security-opt="label=disable" --security-opt=seccomp=unconfirmed "$IMAGE_TAG"
podman run --interactive --tty --env VPN_NODE_DNS="$VPN_NODE_DNS" --env ThisClientName="$THIS_CLIENT_NAME" --env ThisClientAddress="$THIS_CLIENT_ADDRESS" --env VPNName="$VPN_NETWORK" --env VPNPeers="$VPN_PEERS" --env VPNSubnet="$VPN_SUBNET" --env ThisClientUniqueVpnIp="$THIS_CLIENT_UNIQUE_VPN_IP" --publish 655:655 --volume "$TINC_CONFIG_DIR/":/etc/tinc/ --cap-add=NET_ADMIN --device /dev/net/tun --security-opt="label=disable" "$IMAGE_TAG"
