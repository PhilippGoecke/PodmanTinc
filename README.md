# PodmanTinc
Podman Tinc
> Run a secure and decentralized [Tinc VPN](https://tinc-vpn.org/) using Podman containers. 🌐

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/PhilippGoecke/PodmanTin)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

*   🚀 **Easy Deployment:** Get your VPN up and running in minutes.
*   📦 **Containerized:** Isolated and portable environment using Podman.
*   🔒 **Secure:** Leverages Tinc's robust encryption and authentication.
*   🌐 **Decentralized:** Peer-to-peer mesh network with no single point of failure.
*   ⚙️ **Configurable:** Easily customize your network settings.

## 🏁 Getting Started

### Prerequisites

*   [Podman](https://podman.io/getting-started/installation) installed on your system.
*   `git` for cloning the repository.

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/PhilippGoecke/PodmanTinc.git
    cd PodmanTinc
    ```

2.  **Configure your node:**
    - Edit the `Containerfile` to set your node's name and settings.
    - Place the host files for each peer you want to connect with into the `./hosts/` directory.

3.  **Build & Run the container image:**
    - A helper script `podman-run-tinc.bash` is provided to run the container with the correct parameters. Review the script and customize it if needed.
    ```sh
    bash podman-run-tinc.bash
    ```
    - share the public key of this Node with the other Peers

## 🚀 Usage

### Start the VPN Node

Run the container in detached mode. Make sure to mount your configuration directory.
