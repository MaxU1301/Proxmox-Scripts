# Install initial packages
apt install cifs-utils nfs-common
add-apt-repository ppa:zhangsongcui3371/fastfetch
apt install fastfetch

# Install K8s Using kubeadm
ufw disable
swapoff -a; sed -i '/swap/d' /etc/fstab

apt install docker.io apt-transport-https curl ca-certificates gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt install kubeadm kubelet kubectl kubernetes-cni

wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/SetAsK8sMaster.sh
