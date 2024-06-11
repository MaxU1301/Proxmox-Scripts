# --flannel-iface=eth1
sudo apt install -y cifs-utils nfs-common net-tools
curl -sfL https://get.k3s.io | sh -
sleep 10
sudo k3s kubectl get nodes
ip a
sudo cat /var/lib/rancher/k3s/server/node-token