# PodmanTinc
Podman Tinc
> Run a secure and decentralized Tinc VPN using Podman containers. 🌐

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/user/podman-tinc)
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
    git clone https://github.com/your-username/podman-tinc.git
    cd podman-tinc
    ```

2.  **Configure your node:**
    - Edit the `tinc/tinc.conf` to set your node's name.
    - Edit the `tinc/hosts/` files to define your network peers.

3.  **Build the container image:**
    ```sh
    podman build -t podman-tinc .
    ```

## 🚀 Usage

### Start the VPN Node

Run the container in detached mode. Make sure to mount your configuration directory.
