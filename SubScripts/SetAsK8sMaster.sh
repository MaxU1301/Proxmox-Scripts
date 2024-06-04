sudo apt update
sudo apt upgrade -y
sudo apt install kubeadm kubelet kubectl kubernetes-cni
sudo kubeadm init

# Initialize Kubeadm For Current User
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico

# sudo kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml -O
kubectl create -f custom-resources.yaml
watch kubectl get pods -n calico-system

kubeadm token create --print-join-command