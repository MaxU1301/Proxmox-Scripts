sudo apt update
sudo apt install -y mysql-server
sudo mysql -u root -Bse "CREATE DATABASE IF NOT EXISTS k3sdb;USE k3sdb;CREATE USER 'k3s'@'localhost' IDENTIFIED BY 'hightech';GRANT ALL PRIVILEGES ON *.* TO 'k3s'@'localhost' WITH GRANT OPTION;"

