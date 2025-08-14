# How to Set Up a K3s Cluster

This guide provides two methods for setting up a K3s cluster: one using Multipass for local testing and another for a production environment on Proxmox.

## Method 1: Using Multipass for Local Clusters

This method is ideal for creating a local K3s cluster for development and testing purposes.

### Prerequisites

*   [Multipass](https://multipass.run/install) installed on your local machine.

### Steps

1.  **Run the Cluster Setup Script:**

    Execute the `[Multipass]-K3s-Cluster.bash` script to automate the creation of the server and worker nodes.

    ```bash
    ./[Multipass]-K3s-Cluster.bash
    ```

2.  **Verify the Cluster:**

    The script will output a list of all running nodes. You can also manually verify the cluster status:

    ```bash
    multipass list
    multipass exec k3s-server -- sudo k3s kubectl get nodes
    ```

## Method 2: Proxmox-Based Cluster

This method is for setting up a more permanent K3s cluster using Proxmox virtual machines.

### 1. Prepare the Proxmox Template

First, create a VM template in Proxmox to streamline the creation of new nodes.

*   **OS:** Ubuntu 24.04
*   **Packages:** `curl`, `vim`, `git`, `net-tools`, `openssh-server`, `ufw`, `qemu-guest-agent`

The `[Template]-K3s-Ubuntu-24.04.sh` script automates the template setup:

```bash
#!/bin/bash

# Update and upgrade the system
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install necessary packages
sudo apt-get install -y curl vim git net-tools openssh-server ufw

# Configure SSH
sudo sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo systemctl restart sshd

# Configure firewall
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 6443
sudo ufw allow 8006
sudo ufw allow 30000:32767/tcp
sudo ufw --force enable

# Install qemu-guest-agent
sudo apt-get install -y qemu-guest-agent
sudo systemctl start qemu-guest-agent
sudo systemctl enable qemu-guest-agent

# Clean up
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*
sudo truncate -s 0 /etc/machine-id
sudo history -c
```

### 2. Set Up the K3s Server

1.  **Create a VM** from the template and run the following script to install the K3s server:

    ```bash
    # SubScripts/k3s-Install/k3s-Server-Install.sh
    curl -sfL https://get.k3s.io | sh -
    sleep 10
    ```

2.  **Verify the Server:**

    ```bash
    sudo k3s kubectl get nodes
    ```

3.  **Retrieve Connection Details:**

    You will need the server's IP address and node token to connect worker nodes.

    ```bash
    ip a
    sudo cat /var/lib/rancher/k3s/server/node-token
    ```

### 3. Set Up K3s Worker Nodes

1.  **Create VMs** for your worker nodes from the same Proxmox template.

2.  **Connect Workers to the Server:**

    Run the following script on each worker node, replacing the placeholder values with your K3s server's IP and token.

    ```bash
    # SubScripts/k3s-Install/k3s-Worker-Install.sh
    curl -sfL https://get.k3s.io | K3S_URL=https://<SERVER_IP>:6443 K3S_TOKEN=<SERVER_TOKEN> sh -
    ```

    For example:

    ```bash
    curl -sfL https://get.k3s.io | K3S_URL=https://192.168.2.48:6443 K3S_TOKEN=K109ecfa9c266b63e6a0dac7bf9150a98d062ca51d6b351956f3d3d2e6eecdee507::server:60b25e34d9f11ed5f7a2c9c03d808ec6 sh -
    ```

3.  **Verify the Cluster:**

    From the K3s server node, you should now see all connected worker nodes:

    ```bash
    sudo k3s kubectl get nodes
    ```
