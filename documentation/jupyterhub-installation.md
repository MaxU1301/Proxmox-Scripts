# How to Install JupyterHub

This guide explains how to install JupyterHub on a Kubernetes cluster. This setup uses Helm and a custom `config.yaml` file to deploy a JupyterHub instance with specific configurations.

## 1. Prerequisites

*   A running Kubernetes cluster.
*   `helm` installed on your local machine.
*   `kubectl` configured to connect to your Kubernetes cluster.
*   An NFS provisioner set up for dynamic storage. The `config.yaml` specifies `nfs-client` as the storage class.
*   MetalLB or another load balancer solution configured in the cluster.

## 2. Installation Scripts

The installation process is automated by the following scripts:

*   **`InstallAll.sh`**: This is the main script that orchestrates the entire installation process. It calls other scripts to set up dependencies and then installs JupyterHub.
*   **`InstallJupyterHub.sh`**: This script downloads the `config.yaml` file and uses Helm to install or upgrade the JupyterHub release.
*   **`SetupNFSProvisioner.sh`** and **`SetupMetalLB.sh`**: These scripts (not detailed here) are responsible for setting up the necessary storage and load balancing prerequisites.

## 3. Configuration

The JupyterHub installation is configured using the `SubScripts/JupyterHubConfig/config.yaml` file. This file customizes the default JupyterHub Helm chart. Key configurations in this file include:

*   **Ingress**: Enabled to expose JupyterHub to external traffic.
*   **Single User Environment**:
    *   **Image**: Uses a custom Docker image `maxullrich/jupyter-army-education:latest`.
    *   **Default URL**: Redirects users to a specific notebook after login.
    *   **Storage**: Uses a dynamic PVC with the `nfs-client` storage class and requests 50Gi of storage.
    *   **Lifecycle Hooks**: Uses `gitpuller` to pull a Git repository into the user's environment when their server starts.
*   **Hub**:
    *   **Database**: Uses a PVC with the `nfs-client` storage class for the Hub's database.
    *   **Authentication**: Uses `NativeAuthenticator` to allow users to sign up and log in with a username and password.
    *   **Admin Users**: Specifies a list of admin users.
*   **Proxy**:
    *   **Service**: Sets a static `loadBalancerIP` for the proxy service.
    *   **HTTPS**: Enables HTTPS and specifies the hostname and a secret containing the TLS certificate.

## 4. Installation Steps

The `InstallAll.sh` script automates the following steps:

1.  **Sets up the NFS provisioner and MetalLB**.
2.  **Runs the `InstallJupyterHub.sh` script**, which:
    a.  Creates a `jupyterhub` directory.
    b.  Downloads the `config.yaml` file.
    c.  Adds the JupyterHub Helm repository.
    d.  Installs or upgrades the JupyterHub release using Helm, applying the custom configurations from `config.yaml`.
3.  **Applies MetalLB configuration**.
4.  **Cleans up** the installation scripts.
5.  **Downloads an update script** for JupyterHub.
6.  **Starts watching the Kubernetes resources** to show the status of the deployment.

### Running the Installation

To install JupyterHub, run the `InstallAll.sh` script from the `SubScripts` directory:

```bash
cd SubScripts
./InstallAll.sh
```

## 5. Verifying the Installation

After the script finishes, you can verify the installation by checking the status of the pods and services:

```bash
kubectl get pods,svc -n default
```

You should see pods for the JupyterHub hub, proxy, and potentially some user pods. The proxy service should have an external IP address assigned by MetalLB. You can then access the JupyterHub instance by navigating to the hostname specified in the `config.yaml` file.
