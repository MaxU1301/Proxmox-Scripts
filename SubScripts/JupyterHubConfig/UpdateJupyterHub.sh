#!/bin/bash
set -euo pipefail

# Update Config File
if [ -f config.yaml ]; then rm config.yaml; fi
echo "Downloading config.yaml..."
curl -H 'Cache-Control: no-cache, no-store' -O https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/config.yaml \
  || { echo "Error: Failed to download config.yaml. Aborting."; exit 1; }
echo "config.yaml downloaded successfully."

# Update Monitor Script
if [ -f monitorJupyterHub.sh ]; then rm monitorJupyterHub.sh; fi
echo "Downloading monitorJupyterHub.sh..."
curl -H 'Cache-Control: no-cache, no-store' -O https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/monitorJupyterHub.sh \
  || { echo "Error: Failed to download monitorJupyterHub.sh. Aborting."; exit 1; }
chmod +x monitorJupyterHub.sh \
  || { echo "Error: Failed to set execute permissions on monitorJupyterHub.sh. Aborting."; exit 1; }
echo "monitorJupyterHub.sh downloaded and permissions set."

# Update SSL Script
if [ -f SSLUpdate.sh ]; then rm SSLUpdate.sh; fi # Corrected filename here
echo "Downloading SSLUpdate.sh..."
curl -H 'Cache-Control: no-cache, no-store' -O https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/SSLUpdate.sh \
  || { echo "Error: Failed to download SSLUpdate.sh. Aborting."; exit 1; }
chmod +x SSLUpdate.sh \
  || { echo "Error: Failed to set execute permissions on SSLUpdate.sh. Aborting."; exit 1; }
echo "SSLUpdate.sh downloaded and permissions set."

# Update JupyterHub
echo Updating Jupyter Hub
helm upgrade --cleanup-on-fail \
  jupyterhub jupyterhub/jupyterhub \
  --namespace jupyter-hub \
  --version=3.3.0 \
  --timeout 10m0s \
  --values config.yaml \
  || { echo "Error: Helm upgrade failed. Please check the output above for details. Aborting."; exit 1; }
echo "JupyterHub updated successfully via Helm."

# Update Update script
if [ -f UpdateJupyterHub.sh ]; then rm UpdateJupyterHub.sh; fi
echo "Downloading UpdateJupyterHub.sh (self-update)..."
curl -O https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/UpdateJupyterHub.sh \
  || { echo "Error: Failed to download UpdateJupyterHub.sh for self-update. This might indicate network issues."; exit 1; }
chmod +x UpdateJupyterHub.sh \
  || { echo "Error: Failed to set execute permissions on UpdateJupyterHub.sh for self-update. This might indicate permission issues."; exit 1; }
echo "UpdateJupyterHub.sh self-updated successfully."

echo "All updates completed."