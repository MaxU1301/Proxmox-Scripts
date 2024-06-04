mkdir nfs-provisioner
cd nfs-provisioner
rm *

# Download nfs-provisioner scripts
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/nfs-provisioner/rbac.yaml
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/nfs-provisioner/deployment.yaml
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/nfs-provisioner/default-sc.yaml
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/nfs-provisioner/class.yaml

# wget https://raw.githubusercontent.com/justmeandopensource/kubernetes/master/yamls/nfs-provisioner/rbac.yaml
# wget https://raw.githubusercontent.com/justmeandopensource/kubernetes/master/yamls/nfs-provisioner/deployment.yaml
# wget https://raw.githubusercontent.com/justmeandopensource/kubernetes/master/yamls/nfs-provisioner/default-sc.yaml
# wget https://raw.githubusercontent.com/justmeandopensource/kubernetes/master/yamls/nfs-provisioner/class.yaml

# Modify yaml files
echo "edit deployment.yaml"
nano deployment.yaml

sudo kubectl create -f rbac.yaml
sudo kubectl create -f default-sc.yaml
sudo kubectl create -f deployment.yaml
