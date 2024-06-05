# ip range 192.168.1.30-192.168.1.50

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

# Config for MetalLB
sleep 5
kubectl create -f https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/MetalLBconfig/metallb.yaml