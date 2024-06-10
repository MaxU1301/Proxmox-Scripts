#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Update and upgrade packages
sudo apt update
sudo apt upgrade -y

# Install Kubernetes components
sudo apt install kubeadm kubelet kubectl kubernetes-cni -y

# Initialize Kubeadm with a specific pod network CIDR
# sudo kubeadm init --pod-network-cidr=10.1.0.0/16
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Set up kubeconfig for the current user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# # Install Calico for network policies
# kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
# kubectl create -f https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/CalicoConfig/custom-resources.yaml

# # Watch Calico pods until they are all running
# echo "Waiting for Calico pods to be ready..."
# watch 'echo "wait for all to be READY"; kubectl get pods -n calico-system'

# # Allow scheduling on the control-plane node
# kubectl taint nodes --all node-role.kubernetes.io/control-plane-
# kubectl get nodes -o wide

# # Install calicoctl
# cd /usr/local/bin
# sudo curl -L https://github.com/projectcalico/calico/releases/download/v3.28.0/calicoctl-linux-amd64 -o kubectl-calico
# sudo chmod +x kubectl-calico
# cd ~

# Install Flannel
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

watch kubectl get pods -n kube-flannel

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Download additional setup scripts
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/SetupMetalLB.sh
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/SetupNFSProvisioner.sh
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/InstallJupyterHub.sh
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/InstallAll.sh

# Make the scripts executable
sudo chmod +x SetupMetalLB.sh
sudo chmod +x SetupNFSProvisioner.sh
sudo chmod +x InstallJupyterHub.sh
sudo chmod +x InstallAll.sh

# Output instructions for the next steps
echo "Please run SetupNFSProvisioner.sh and SetupMetalLB.sh"

# Generate the kubeadm join command
kubeadm token create --print-join-command