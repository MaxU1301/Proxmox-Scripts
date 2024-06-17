# Update Config File
sudo rm config.yaml
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/config.yaml

client_secret_secret="$(grep -n "client_secret" secrets.yaml | head -n 1 | cut -d: -f1)"
client_id_secret="$(grep -n "client_id" secrets.yaml | head -n 1 | cut -d: -f1)"

client_secret_config="$(grep -n "client_secret" config.yaml | head -n 1 | cut -d: -f1)"
client_id_config="$(grep -n "client_id" config.yaml | head -n 1 | cut -d: -f1)"

client_secret="$(awk NR=="$client_secret_secret" secrets.yaml)"
client_id="$(awk NR=="$client_id_secret" secrets.yaml)"

sed -i -e s/client_id:/"$client_id"/g config.yaml
sed -i -e s/client_secret:/"$client_secret"/g config.yaml

echo client_secret

sudo rm monitorJupyterHub.sh
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/monitorJupyterHub.sh
chmod +x monitorJupyterHub.sh

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