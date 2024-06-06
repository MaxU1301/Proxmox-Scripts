#!/bin/bash

./SetupNFSProvisioner.sh
./SetupMetalLB.sh
./InstallJupyterHub.sh

sudo rm SetupNFSProvisioner.sh
sudo rm SetupMetalLB.sh
sudo rm InstallJupyterHub.sh
sudo rm SetAsK8sMaster.sh
sudo rm InstallAll.sh

wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/UpdateJupyterHub.sh
chmod +x UpdateJupyterHub.sh

watch kubectl get all