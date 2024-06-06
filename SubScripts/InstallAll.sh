#!/bin/bash

./SetupNFSProvisioner.sh
./SetupMetalLB.sh
./InstallJupyterHub.sh

rm SetupNFSProvisioner.sh
rm SetupMetalLB.sh
rm InstallJupyterHub.sh
rm SetAsK8sMaster.sh
rm InstallAll.sh

wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/JupyterHubConfig/UpdateJupyterHub.sh
chmod +x UpdateJupyterHub.sh