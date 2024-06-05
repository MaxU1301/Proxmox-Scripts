sudo apt update
sudo apt upgrade -y
sudo apt install kubeadm kubelet kubectl kubernetes-cni -y
sudo kubeadm init --pod-network-cidr=192.168.0.0/22 # --apiserver-advertise-address=192.168.2.6

# Initialize Kubeadm For Current User
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/CalicoConfig/custom-resources.yaml

watch kubectl get pods -n calico-system
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl get nodes -o wide

# Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Download MetalLB and NFS Scripts
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/SetupMetalLB.sh
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/SetupNFSProvisioner.sh
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/InstallJupyterHub.sh

sudo chmod +x SetupMetalLB.sh
sudo chmod +x SetupNFSProvisioner.sh
sudo chmod +x InstallJupyterHub.sh

echo "Please run SetupNFSProvisioner.sh and SetupMetalLB.sh"
kubeadm token create --print-join-command