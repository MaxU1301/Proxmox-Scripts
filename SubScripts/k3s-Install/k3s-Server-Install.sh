# --flannel-iface=eth1
curl -sfL https://get.k3s.io | sh -s - server
sudo k3s kubectl get nodes
ip a
sudo cat /var/lib/rancher/k3s/server/node-token