# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Setup nfs provisioner
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=141.215.12.28 \
    --set nfs.path=/mnt/UMDSC-Storage-1/JupyterHubUserStorage \
    --set storageClass.archiveOnDelete=false \
    --set storageClass.defaultClass=false \
    --set storageClass.name=nfs-client \
    --set storageClass.accessModes=ReadWriteOnce

# Install Rancher
# helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
# kubectl create namespace cattle-system

# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.crds.yaml
# helm repo add jetstack https://charts.jetstack.io
# helm repo update
# helm install cert-manager jetstack/cert-manager \
#   --namespace cert-manager \
#   --create-namespace \
#   --set installCRDs=true

# helm install rancher rancher-latest/rancher \
#   --namespace cattle-system \
#   --set hostname=rancher.tothemax.pro \
#   --set bootstrapPassword=admin

# kubectl -n cattle-system rollout status deploy/rancher
# kubectl expose deployment rancher --name rancher-lb --port=443 --type=LoadBalancer -n cattle-system service/rancher-lb exposed

# Setup Jupyterhub
mkdir jupyterhub
cd jupyterhub
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/config.yaml
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/secrets.yaml
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/UpdateJupyterHub.sh
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/monitorJupyterHub.sh
chmod +x UpdateJupyterHub.sh
chmod +x monitorJupyterHub.sh

# Install jupyterhub
helm repo add jupyterhub https://hub.jupyter.org/helm-chart/
helm repo update

helm upgrade --cleanup-on-fail \
  --install jupyterhub jupyterhub/jupyterhub \
  --namespace jupyter-hub \
  --create-namespace \
  --version=3.3.0 \
  --timeout 10m0s \
  --values config.yaml

# Monitor Jupyter Hub
watch -n 0.1 kubectl get all -n jupyter-hub -o wide