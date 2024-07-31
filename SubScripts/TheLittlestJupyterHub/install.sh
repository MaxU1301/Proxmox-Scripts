# Install tljh
sudo apt install python3 python3-dev git curl
curl -L https://tljh.jupyter.org/bootstrap.py | sudo -E python3 - --admin max

# Set native authenticator as default
sudo tljh-config set auth.type nativeauthenticator.NativeAuthenticator
sudo tljh-config reload

sudo touch /opt/tljh/config/jupyterhub_config.d/nativeauth.py

echo "import os, nativeauthenticator" | sudo tee -a /opt/tljh/config/jupyterhub_config.d/nativeauth.py
echo 'c.JupyterHub.template_paths = [f"{os.path.dirname(nativeauthenticator.__file__)}/templates/"]' | sudo tee -a /opt/tljh/config/jupyterhub_config.d/nativeauth.py

# Set timeout to 1 hr
sudo tljh-config set services.cull.timeout 3600
sudo tljh-config reload

# Mount Storage Server
sudo mkdir /mnt/LabStorage
echo "192.168.12.28:/mnt/UMDSC-Storage-1/LabStorage /mnt/LabStorage nfs defaults 0 0" | sudo tee -a /etc/fstab
sudo systemctl daemon-reload
sudo mount /mnt/LabStorage

sudo ln -s /mnt/LabStorage /etc/skel/LabStorage