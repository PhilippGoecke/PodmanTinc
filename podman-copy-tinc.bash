# Configuration
VPN_NETWORK="yourtincvpnname"

# Copy required tinc files from a container to ./$VPN_NETWORK/...
copy_tinc_files() {
    local container_name="${1:-tinc}"
    local dest_dir="./$VPN_NETWORK"

    mkdir -p "$dest_dir/hosts"

    podman cp "$container_name:/etc/tinc/$VPN_NETWORK/tinc.conf" "$dest_dir/tinc.conf"
    podman cp "$container_name:/etc/tinc/$VPN_NETWORK/tinc-up" "$dest_dir/tinc-up"
    podman cp "$container_name:/etc/tinc/$VPN_NETWORK/tinc-down" "$dest_dir/tinc-down"
    podman cp "$container_name:/etc/tinc/$VPN_NETWORK/rsa_key.priv" "$dest_dir/rsa_key.priv"
    podman cp "$container_name:/etc/tinc/$VPN_NETWORK/hosts/." "$dest_dir/hosts/"
}

# Usage: copy_tinc_files <container-name-or-id>
