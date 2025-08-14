# How to Set Up a High-Availability K3s Cluster

This guide explains how to set up a high-availability K3s cluster with an embedded database. This setup uses `k3sup` and `kube-vip` to create a multi-master cluster that is resilient to single-node failures.

## 1. Prerequisites

*   **Three or more servers** for the master nodes.
*   **One or more servers** for the worker nodes.
*   **A dedicated virtual IP (VIP)** address for the Kubernetes API server.
*   **SSH access** to all nodes from the machine where you will run the deployment script.
*   **`k3sup` and `kubectl`** installed on your local machine.

## 2. Configuration

The `HA-k3s-install.sh` script is used to automate the setup. Before running it, you need to configure the following variables within the script:

*   `KVVERSION`: The version of `kube-vip` to deploy.
*   `k3sVersion`: The version of K3s to install.
*   `master1`, `master2`, `master3`: IP addresses of the master nodes.
*   `worker1`, `worker2`, ...: IP addresses of the worker nodes.
*   `user`: The SSH username for the remote machines.
*   `interface`: The network interface to use on the remote machines (e.g., `eth0`).
*   `vip`: The virtual IP address for the cluster.
*   `lbrange`: The IP address range for the MetalLB load balancer.
*   `certName`: The name of your SSH private key file (e.g., `id_rsa`).

## 3. Deployment Steps

The `HA-k3s-install.sh` script performs the following steps:

1.  **Installs `k3sup` and `kubectl`** on the local machine if they are not already present.
2.  **Sets up SSH keys** for passwordless access to all nodes.
3.  **Installs `policycoreutils`** on all nodes.
4.  **Bootstraps the first master node** using `k3sup`. This includes:
    *   Disabling the default `traefik` ingress controller and `servicelb`.
    *   Configuring `flannel` to use the specified network interface.
    *   Tainting the master node to prevent regular workloads from being scheduled on it.
5.  **Deploys `kube-vip`** to the first master node to provide high availability for the Kubernetes API server.
6.  **Joins the remaining master nodes** to the cluster.
7.  **Joins the worker nodes** to the cluster.
8.  **Installs MetalLB** as a load balancer for services.
9.  **Deploys a sample NGINX application** to test the cluster and load balancer.

### Running the Script

Once you have configured the variables, run the script to deploy the cluster:

```bash
./SubScripts/k3s-Install/HA-k3s-install.sh
```

## 4. Verifying the Cluster

After the script completes, it will output the status of all nodes, services, and pods.

You can manually verify the cluster status at any time:

*   **Check the nodes:**
    ```bash
    kubectl get nodes -o wide
    ```
*   **Check the services:**
    ```bash
    kubectl get svc --all-namespaces
    ```
*   **Check the pods:**
    ```bash
    kubectl get pods --all-namespaces -o wide
    ```

You should see all master and worker nodes in a `Ready` state. The NGINX service should have an external IP address from the MetalLB address pool.
