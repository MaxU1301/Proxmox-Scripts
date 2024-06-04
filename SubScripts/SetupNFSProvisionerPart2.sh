cd nfs-provisioner

# Setup NFS provisioner
sudo kubectl create -f rbac.yaml
sudo kubectl create -f default-sc.yaml
