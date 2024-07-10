# Terraform Configuration for Talos Kubernetes Cluster

This Terraform project automates the deployment of a Talos Kubernetes cluster on Proxmox virtual machines. It includes the setup of the Kubernetes nodes, bootstrapping the Talos control plane, and generating the necessary configuration files for cluster management.

## Overview

The configuration defines resources for deploying VMs on Proxmox, configuring Talos machines, and generating local files for Talos and Kubernetes cluster management. It leverages variables for customization and modularity.

### Key Components

- **Proxmox VMs**: Virtual machines for the Kubernetes nodes are provisioned on a Proxmox VE cluster.
- **Talos Machine Bootstrap**: Initializes the Talos control plane on the designated control plane node.
- **Local Files**: Configuration files for Talos and Kubernetes (`talosconfig` and `kubeconfig`) are generated and stored locally for cluster administration.

## Prerequisites

- **Proxmox VE Cluster**: A running Proxmox VE cluster where the Kubernetes nodes will be deployed.
- **Terraform**: Terraform must be installed on your machine to execute the configuration.
- **Talos CLI**: For interacting with the Talos cluster post-deployment.

## Configuration

Before applying the Terraform configuration, ensure you have configured the necessary variables in your `terraform.tfvars` file or equivalent. Key variables include:

- `nameservers`: Specifies the DNS servers for the VMs.
- [`install_disk`](command:_github.copilot.openSymbolFromReferences?%5B%7B%22%24mid%22%3A1%2C%22path%22%3A%22%2Fhome%2Fboboysdadda%2Fprojects%2Fgitops-homelab%2Fterraform%2Fvariables.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%7B%22line%22%3A67%2C%22character%22%3A0%7D%5D "terraform/variables.tf"): Defines the disk where Talos OS will be installed.
- [`nodes`](command:_github.copilot.openSymbolFromReferences?%5B%7B%22%24mid%22%3A1%2C%22path%22%3A%22%2Fhome%2Fboboysdadda%2Fprojects%2Fgitops-homelab%2Fterraform%2Fproxmox-nodes.tf%22%2C%22scheme%22%3A%22file%22%7D%2C%7B%22line%22%3A0%2C%22character%22%3A0%7D%5D "terraform/proxmox-nodes.tf"): A map defining the node names and roles within the cluster.

## Usage

1. **Initialize Terraform**

```bash
terraform init
```

2. **Plan the Deployment**

Review the actions Terraform will perform before applying them.

```bash
terraform plan
```

3. **Apply the Configuration**

Deploy the Kubernetes cluster on Proxmox.

```bash
terraform apply
```

4. **Access the Cluster**

After deployment, use the generated `kubeconfig` file to access your Kubernetes cluster.

```bash
export KUBECONFIG=./kubeconfig
kubectl get nodes
```

## Managing the Cluster

- **Talos Configuration**: The `talosconfig` file contains credentials and endpoints for managing the Talos cluster. Use the Talos CLI to interact with your cluster.
- **Kubernetes Configuration**: The `kubeconfig` file allows you to manage your Kubernetes cluster using `kubectl` or other Kubernetes tools.

## Conclusion

This Terraform project simplifies the process of deploying and managing a Talos Kubernetes cluster on Proxmox. Customize the configuration to suit your infrastructure and requirements.


## Notes that need sorted
static IPs are really hard with talos on first boot. cheat and set a static IP in your dhcp server with some reserved macs that you will apply to your nodes. Generate unicast macs here: https://www.hellion.org.uk/cgi-bin/randmac.pl?scope=local&type=unicast 