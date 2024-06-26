# Download config.yaml
mkdir jupyterhub
cd jupyterhub
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/config.yaml

# Install jupyterhub
helm repo add jupyterhub https://hub.jupyter.org/helm-chart/
helm repo update

helm upgrade --cleanup-on-fail \
  --install jupyterhub jupyterhub/jupyterhub \
  --namespace default \
  --version=3.3.0 \
  --timeout 10m0s \
  --values config.yaml

  # --create-namespace \