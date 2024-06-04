sudo apt update
sudo apt upgrade -y
sudo apt install kubeadm kubelet kubectl kubernetes-cni
sudo kubeadm init -pod-network-cidr=192.168.0.0/22

# Initialize Kubeadm For Current User
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico

# sudo kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml

# sudo kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/calico.yaml

# Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Download MetalLB and NFS Scripts
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/SetupMetalLB.sh
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/SetupNFSProvisioner.sh

sudo chmod +x SetupMetalLB.sh
sudo chmod +x SetupNFSProvisioner.sh

echo "Please run SetupNFSProvisioner.sh and SetupMetalLB.sh"
kubeadm token create --print-join-command