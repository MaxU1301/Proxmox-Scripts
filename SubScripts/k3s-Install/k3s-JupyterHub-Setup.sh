# curl https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/k3s-Install/k3s-JupyterHub-Setup.sh | bash
sudo mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo cp /etc/rancher/k3s/k3s.yaml /root/.kube/config

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ip range 192.168.1.30-192.168.1.50

sudo k3s kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

# Config for MetalLB
sleep 30
sudo k3s kubectl create -f https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/MetalLBconfig/metallb.yaml

# Setup nfs provisioner
sudo helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
sudo helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=141.215.12.28 \
    --set nfs.path=/mnt/UMDSC-Storage-1/JupyterHubUserStorage \
    --set storageClass.archiveOnDelete=false \
    --set storageClass.defaultClass=false \
    --set storageClass.name=nfs-client \
    --set storageClass.accessModes=ReadWriteOnce

# Install Rancher
# sudo helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
# sudo kubectl create namespace cattle-system

# sudo kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.crds.yaml
# sudo helm repo add jetstack https://charts.jetstack.io
# sudo helm repo update
# sudo helm install cert-manager jetstack/cert-manager \
#   --namespace cert-manager \
#   --create-namespace \
#   --set installCRDs=true

# sudo helm install rancher rancher-latest/rancher \
#   --namespace cattle-system \
#   --set hostname=rancher.tothemax.pro \
#   --set bootstrapPassword=admin

# sudo kubectl -n cattle-system rollout status deploy/rancher
# sudo kubectl expose deployment rancher --name rancher-lb --port=443 --type=LoadBalancer -n cattle-system service/rancher-lb exposed

# Setup Jupyterhub
# Download config.yaml
mkdir jupyterhub
cd jupyterhub
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/config.yaml
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/secrets.yaml
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/UpdateJupyterHub.sh
sudo chmod +x UpdateJupyterHub.sh

# Install jupyterhub
sudo helm repo add jupyterhub https://hub.jupyter.org/helm-chart/
sudo helm repo update

sudo helm upgrade --cleanup-on-fail \
  --install jupyterhub jupyterhub/jupyterhub \
  --namespace jupyter-hub \
  --create-namespace \
  --version=3.3.0 \
  --timeout 10m0s \
  --values config.yaml

watch -n 0.1 sudo kubectl get all -n jupyter-hub -o wide