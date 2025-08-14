# How to Create a Proxmox VM Template

This guide explains how to create a Proxmox VM template for Ubuntu 24.04. This template can be used to quickly deploy new VMs with a standard configuration.

## 1. Create a New Virtual Machine

Start by creating a new VM in Proxmox with the following specifications:

*   **OS:** Ubuntu 24.04
*   **CPU:** 1 or more cores
*   **Memory:** 2GB or more
*   **Disk:** 20GB or more

## 2. OS Installation and Initial Setup

1.  **Install Ubuntu 24.04** on the VM.
2.  **Log in to the VM** and open a terminal.

## 3. Run the Template Script

The `[Template]-K3s-Ubuntu-24.04.sh` script automates the process of configuring the VM to be a template.

### Script Content

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

### Running the Script

1.  **Copy the script** to the VM or create a new file and paste the content.
2.  **Make the script executable:**
    ```bash
    chmod +x [Template]-K3s-Ubuntu-24.04.sh
    ```
3.  **Run the script:**
    ```bash
    ./[Template]-K3s-Ubuntu-24.04.sh
    ```

## 4. Final Steps

1.  **Shut down the VM** from the Proxmox web interface.
2.  **Convert the VM to a template.** Right-click the VM in the Proxmox interface and select "Convert to template".

## 5. Using the Template

You can now create new VMs by cloning this template. When you clone the template, you can specify the hostname, IP address, and other settings for the new VM. This process significantly speeds up the deployment of new VMs with a consistent configuration.
