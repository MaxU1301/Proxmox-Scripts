# Proxmox Scripts

This repository contains a collection of scripts to automate the setup and management of Proxmox virtual machines, Kubernetes clusters, and various applications. The scripts are designed to streamline the process of creating development and production environments.

## Overview

The scripts in this project can be used to:

*   Create Proxmox VM templates for different Kubernetes distributions (K3s, K0s).
*   Set up standalone and high-availability K3s clusters.
*   Install and configure JupyterHub on Kubernetes.
*   Install and configure The Littlest JupyterHub (TLJH).

## Documentation

For detailed instructions on how to use these scripts, please refer to the documentation files in the `documentation` directory:

*   [**Proxmox VM Template Creation**](./documentation/proxmox-template-creation.md): Learn how to create a reusable VM template in Proxmox.
*   [**K3s Cluster Setup**](./documentation/k3s-cluster-setup.md): A guide to setting up a single-node or multi-node K3s cluster.
*   [**High-Availability K3s Cluster Setup**](./documentation/k3s-high-availability-setup.md): Instructions for creating a resilient, multi-master K3s cluster.
*   [**JupyterHub Installation on Kubernetes**](./documentation/jupyterhub-installation.md): A walkthrough of deploying JupyterHub on a Kubernetes cluster using Helm.
*   [**The Littlest JupyterHub (TLJH) Installation**](./documentation/tljh-installation.md): A guide to installing TLJH on a single server.
