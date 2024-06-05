# Install initial packages
apt install cifs-utils nfs-common net-tools -y
# ip route  ##make sure there is only one default route on the main ip
# sudo route delete default gw 172.22.64.1 eth0
add-apt-repository ppa:zhangsongcui3371/fastfetch
sudo apt update
apt install fastfetch -y

# Install K8s Using kubeadm
ufw disable
swapoff -a; sed -i '/swap/d' /etc/fstab

apt install docker.io apt-transport-https curl ca-certificates gpg -y
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt update
apt upgrade -y
apt install kubeadm kubelet kubectl kubernetes-cni -y

wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/SetAsK8sMaster.sh
sudo chmod +x SetAsK8sMaster.sh