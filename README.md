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

If a namespace gets stuck on destroy
  1. cancel the destroy
  2. Run the following script 
 ```
kubectl get namespace "stucked-namespace" -o json \
  | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
  | kubectl replace --raw /api/v1/namespaces/stucked-namespace/finalize -f -
```
  3. reapply the destroy

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | 4.37.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.10.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.31.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.1-rc3 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.31.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.11.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd"></a> [argocd](#module\_argocd) | git@github.com:jamesAtIntegratnIO/terraform-helm-gitops-bridge | homelab |
| <a name="module_cloudflare"></a> [cloudflare](#module\_cloudflare) | ./modules/cloudflare | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | ./modules/cluster | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.op_connect](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/namespace) | resource |
| [kubernetes_secret.docker-config](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/secret) | resource |
| [kubernetes_secret.onepassword_token](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/secret) | resource |
| [kubernetes_secret.op_credentials](https://registry.terraform.io/providers/hashicorp/kubernetes/2.31.0/docs/resources/secret) | resource |
| [time_sleep.wait_for_cluster](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr"></a> [cidr](#input\_cidr) | n/a | `number` | n/a | yes |
| <a name="input_cloudflare_api_key"></a> [cloudflare\_api\_key](#input\_cloudflare\_api\_key) | n/a | `string` | n/a | yes |
| <a name="input_cloudflare_records"></a> [cloudflare\_records](#input\_cloudflare\_records) | n/a | <pre>map(object({<br>    name    = string<br>    value   = string<br>    type    = string<br>    ttl     = number<br>    proxied = bool<br>  }))</pre> | n/a | yes |
| <a name="input_cloudflare_zone_name"></a> [cloudflare\_zone\_name](#input\_cloudflare\_zone\_name) | n/a | `string` | n/a | yes |
| <a name="input_cluster_endpoint_ip"></a> [cluster\_endpoint\_ip](#input\_cluster\_endpoint\_ip) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_extra_manifests"></a> [extra\_manifests](#input\_extra\_manifests) | n/a | `list(string)` | `[]` | no |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | n/a | `string` | n/a | yes |
| <a name="input_gitops_addons_basepath"></a> [gitops\_addons\_basepath](#input\_gitops\_addons\_basepath) | n/a | `string` | `""` | no |
| <a name="input_gitops_addons_org"></a> [gitops\_addons\_org](#input\_gitops\_addons\_org) | n/a | `string` | `"https://github.com/jamesatintegratnio"` | no |
| <a name="input_gitops_addons_path"></a> [gitops\_addons\_path](#input\_gitops\_addons\_path) | n/a | `string` | `"bootstrap/control-plane/addons"` | no |
| <a name="input_gitops_addons_repo"></a> [gitops\_addons\_repo](#input\_gitops\_addons\_repo) | n/a | `string` | `"gitops-bridge-argocd-control-plane"` | no |
| <a name="input_gitops_addons_revision"></a> [gitops\_addons\_revision](#input\_gitops\_addons\_revision) | n/a | `string` | `"homelab"` | no |
| <a name="input_install_disk"></a> [install\_disk](#input\_install\_disk) | n/a | `string` | `"/dev/sda"` | no |
| <a name="input_ip_base"></a> [ip\_base](#input\_ip\_base) | n/a | `string` | n/a | yes |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | n/a | `list(string)` | `[]` | no |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | n/a | <pre>map(object({<br>    name             = string<br>    cpu_sockets      = number<br>    cpu_cores        = number<br>    memory           = number<br>    target_node_name = string<br>    disk_size        = string<br>    macaddr          = string<br><br>    controlplane = optional(bool, false)<br>  }))</pre> | n/a | yes |
| <a name="input_onepassword_credentials"></a> [onepassword\_credentials](#input\_onepassword\_credentials) | n/a | `string` | n/a | yes |
| <a name="input_onepassword_token"></a> [onepassword\_token](#input\_onepassword\_token) | n/a | `string` | n/a | yes |
| <a name="input_proxmox_image"></a> [proxmox\_image](#input\_proxmox\_image) | n/a | `string` | `"local:iso/talos-metal-qemu-1.7.5.iso"` | no |
| <a name="input_proxmox_storage"></a> [proxmox\_storage](#input\_proxmox\_storage) | n/a | `string` | `"local-zfs"` | no |
| <a name="input_skip_cluster_wait"></a> [skip\_cluster\_wait](#input\_skip\_cluster\_wait) | n/a | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->