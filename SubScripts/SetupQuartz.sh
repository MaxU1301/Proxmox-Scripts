 # Install Node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 20

# Install Nginx
sudo apt install Nginx

# Authenticate GH
gh auth login

# Create www Directory
sudo mkdir /www
cd /
sudo chmod ugo+rwx www
cd /wwww

# Clone repos
git clone https://github.com/jackyzha0/quartz.git
git clone https://github.com/mullrich-umd/Lab-Documentation

# Initialize quartz
cd quartz
npm i
npx quartz create

# Create NGINX Config
ipaddr=\$(ip a s eth0 | grep -E -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d' ' -f2)
echo "
server {
  listen 80;
  server_name $ipaddr;
  root /www/quartz/public;
  index index.html;
  error_page 404 /404.html;

  location / {
        try_files \$uri \$uri.html \$uri/ =404;
        }
 }
" | sudo tee -a /etc/nginx/conf.d/quartz.conf

# Update Server Script
echo "
cd /www/Lab-Documentation
git pull
cd /www/quartz
npx quartz update
rm -r public
npx quartz build
sudo systemctl restart nginx" >> ~/update-server.sh

cd /www/quartz
npx quartz build
