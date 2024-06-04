# ip range 192.168.1.30-192.168.1.50

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

# Config for MetalLB
mkdir MetalLBconfig
cd MetalLBconfig
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/MetalLBconfig/metallb.yaml

sudo nano metallb.yaml

kubectl create -f metallb.yaml