# Update Config File
if [ -f config.yaml ]; then rm config.yaml; fi
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/config.yaml

if [ -f monitorJupyterHub.sh ]; then rm monitorJupyterHub.sh; fi
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/monitorJupyterHub.sh
chmod +x monitorJupyterHub.sh

# Update JupyterHub
echo Updating Jupyter Hub
helm upgrade --cleanup-on-fail \
  jupyterhub jupyterhub/jupyterhub \
  --namespace jupyter-hub \
  --version=3.3.0 \
  --timeout 10m0s \
  --values config.yaml

# Update Update script
if [ -f UpdateJupyterHub.sh ]; then rm UpdateJupyterHub.sh; fi
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/UpdateJupyterHub.sh
chmod +x UpdateJupyterHub.sh