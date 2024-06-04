# ip range 192.168.1.30-192.168.1.50

helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb

kubectl create -f 