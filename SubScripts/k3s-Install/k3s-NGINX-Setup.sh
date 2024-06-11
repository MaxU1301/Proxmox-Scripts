sudo apt update
sudo apt install -y nginx
sudo rm /etc/nginx/nginx.conf
sudo curl https://raw.githubusercontent.com/MaxU1301/Proxmox-Scripts/main/SubScripts/k3s-Install/k3s-nginx.conf -o nginx.conf