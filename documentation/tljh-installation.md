# How to Install The Littlest JupyterHub (TLJH)

This guide explains how to install and configure The Littlest JupyterHub (TLJH) on a single server.

## 1. Prerequisites

*   A server running a fresh installation of Ubuntu.
*   The server should have at least 1GB of RAM.

## 2. Installation

The installation is performed using a bootstrap script provided by the TLJH project.

1.  **Install dependencies:**
    ```bash
    sudo apt install python3 python3-dev git curl
    ```

2.  **Run the TLJH bootstrap script:**
    This command will download and execute the bootstrap script. The `--admin max` flag designates the user `max` as an administrator.
    ```bash
    curl -L https://tljh.jupyter.org/bootstrap.py | sudo -E python3 - --admin max
    ```

## 3. Configuration

After the installation is complete, you need to configure TLJH.

### 1. Set Native Authenticator

This allows users to sign up and log in with a username and password.

1.  **Set the authenticator type:**
    ```bash
    sudo tljh-config set auth.type nativeauthenticator.NativeAuthenticator
    ```

2.  **Create a configuration file for the native authenticator templates:**
    ```bash
    sudo touch /opt/tljh/config/jupyterhub_config.d/nativeauth.py
    echo "import os, nativeauthenticator" | sudo tee -a /opt/tljh/config/jupyterhub_config.d/nativeauth.py
    echo 'c.JupyterHub.template_paths = [f"{os.path.dirname(nativeauthenticator.__file__)}/templates/"]' | sudo tee -a /opt/tljh/config/jupyterhub_config.d/nativeauth.py
    ```

3.  **Reload the configuration:**
    ```bash
    sudo tljh-config reload
    ```

### 2. Set User Server Timeout

This configuration will automatically shut down user servers after a period of inactivity.

1.  **Set the timeout to 1 hour (3600 seconds):**
    ```bash
    sudo tljh-config set services.cull.timeout 3600
    ```

2.  **Reload the configuration:**
    ```bash
    sudo tljh-config reload
    ```

## 4. Mount Network Storage

This section explains how to mount a network storage location (NFS) and make it available to all users.

1.  **Create a mount point:**
    ```bash
    sudo mkdir /mnt/LabStorage
    ```

2.  **Add the NFS share to `/etc/fstab`:**
    This will automatically mount the share on boot. Replace `192.168.12.28:/mnt/UMDSC-Storage-1/LabStorage` with the actual path to your NFS share.
    ```bash
    echo "192.168.12.28:/mnt/UMDSC-Storage-1/LabStorage /mnt/LabStorage nfs defaults 0 0" | sudo tee -a /etc/fstab
    ```

3.  **Mount the share:**
    ```bash
    sudo systemctl daemon-reload
    sudo mount /mnt/LabStorage
    ```

4.  **Create a symbolic link for new users:**
    This will create a symbolic link to the network storage in the home directory of all new users.
    ```bash
    sudo ln -s /mnt/LabStorage /etc/skel/LabStorage
    ```

## 5. Accessing JupyterHub

After the installation and configuration are complete, you can access the JupyterHub instance by navigating to the IP address of your server in a web browser.
