#!/bin/bash

# Exit on any error
set -e

# Install initial packages
apt install -y cifs-utils nfs-common net-tools

# Ensure there's only one default route on the main IP (commented out, as it needs to be manually verified)
# ip route
# route delete default gw 172.22.64.1 eth0

# Add repository and install fastfetch
add-apt-repository -y ppa:zhangsongcui3371/fastfetch
apt update
apt install -y fastfetch

# Install K0s Master
curl -sSLf https://get.k0s.sh | sudo sh
mkdir -p /etc/k0s
k0s config create > /etc/k0s/k0s.yaml
sudo k0s install controller -c /etc/k0s/k0s.yaml
sudo k0s start
sudo k0s token create --role=worker