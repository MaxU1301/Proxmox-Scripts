#!/bin/bash

# Exit on any error
set -e

# Install initial packages
apt install -y cifs-utils nfs-common net-tools

# Ensure there's only one default route on the main IP (commented out, as it needs to be manually verified)
# ip route
# route delete default gw 172.22.64.1 eth0

# Add repository and install fastfetch
add-apt-repository -y ppa:zhangsongcui3371/fastfetch
apt update
apt install -y fastfetch

ufw disable
swapoff -a
sed -i '/swap/d' /etc/fstab

# Install Docker and dependencies for Kubernetes
sudo apt remove docker docker.io containerd runc

sudo apt-get update

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io

cat <<EOF | sudo tee /etc/docker/daemon.json
{ 
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": { "max-size": "50m" },
  "storage-driver": "overlay2" 
} 
EOF

sudo systemctl enable docker

sudo systemctl daemon-reload

sudo systemctl restart docker

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update 
sudo apt-get install -y kubelet kubeadm kubectl 
sudo apt-mark hold kubelet kubeadm kubectl

# Update and upgrade the system
apt update
apt upgrade -y

# Install Kubernetes components
apt install -y kubeadm kubelet kubectl kubernetes-cni

# Download and set permissions for the K8s master setup script
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/SetAsK8sMaster.sh
sudo chmod +x SetAsK8sMaster.sh

echo "Script completed successfully."