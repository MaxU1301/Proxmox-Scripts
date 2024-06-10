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

# Install Docker and dependencies for Kubernetes
ufw disable
swapoff -a
sed -i '/swap/d' /etc/fstab

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install cri-dockerd
# wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.14/cri-dockerd-0.3.14.amd64.tgz
# tar xvf cri-dockerd-0.3.14.amd64.tgz
# ./cri-dockerd/cri-dockerd

# rm -rf cri-dockerd
# rm cri-dockerd-0.3.14.amd64.tgz

apt install -y apt-transport-https curl ca-certificates gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update and upgrade the system
apt update
apt upgrade -y

# Install Kubernetes components
apt install -y kubeadm kubelet kubectl kubernetes-cni

# Download and set permissions for the K8s master setup script
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/SetAsK8sMaster.sh
sudo chmod +x SetAsK8sMaster.sh

echo "Script completed successfully."