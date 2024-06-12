# Update Config File
sudo rm config.yaml
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/config.yaml

# Update JupyterHub
sudo helm upgrade --cleanup-on-fail \
  jupyterhub jupyterhub/jupyterhub \
  --namespace jupyter-hub \
  --version=3.3.0 \
  --timeout 10m0s \
  --values config.yaml

# Update Update script
sudo rm UpdateJupyterHub.sh
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/UpdateJupyterHub.sh
chmod +x UpdateJupyterHub.sh