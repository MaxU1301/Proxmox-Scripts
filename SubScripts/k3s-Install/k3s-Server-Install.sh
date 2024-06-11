export K3S_DATASTORE_ENDPOINT='mysql://k3s:hightech@tcp(192.168.2.167:3306)/k3sdb'
curl -sfL https://get.k3s.io | sh -s - server --node-taint CriticalAddonsOnly=true:NoExecute --tls-san 192.168.2.172