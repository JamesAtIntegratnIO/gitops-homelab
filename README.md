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
### Proxmox Provider

A Terraform provider is responsible for understanding API interactions and exposing resources. The Proxmox provider uses
the Proxmox API. This provider exposes two resources: [proxmox_vm_qemu](resources/vm_qemu.md)
and [proxmox_lxc](resources/lxc.md).

#### Creating the Proxmox user and role for terraform

The particular privileges required may change but here is a suitable starting point rather than using cluster-wide
Administrator rights

Log into the Proxmox cluster or host using ssh (or mimic these in the GUI) then:

- Create a new role for the future terraform user.
- Create the user "terraform-prov@pve"
- Add the TERRAFORM-PROV role to the terraform-prov user

```bash
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
pveum user add terraform-prov@pve --password <password>
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

The provider also supports using an API key rather than a password, see below for details.

After the role is in use, if there is a need to modify the privileges, simply issue the command showed, adding or
removing privileges as needed.


Proxmox > 8:
```bash
pveum role modify TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
```
Proxmox < 8:
```bash
pveum role modify TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt"
```
For more information on existing roles and privileges in Proxmox, refer to the vendor docs
on [PVE User Management](https://pve.proxmox.com/wiki/User_Management)

#### Creating the connection via username and password

When connecting to the Proxmox API, the provider has to know at least three parameters: the URL, username and password.
One can supply fields using the provider syntax in Terraform. It is recommended to pass secrets through environment
variables.

```bash
export PM_USER="terraform-prov@pve"
export PM_PASS="password"
```

Note: these values can also be set in main.tf but users are encouraged to explore Vault as a way to remove secrets from
their HCL.

```hcl
provider "proxmox" {
  pm_api_url = "https://proxmox-server01.example.com:8006/api2/json"
}
```

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

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->   