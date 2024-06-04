# ip range 192.168.1.30-192.168.1.50

helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb

# Config for MetalLB
mkdir MetalLBconfig
cd MetalLBconfig
wget https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/MetalLBconfig/metallb.yaml

nano metallb.yaml

kubectl create -f metallb.yaml