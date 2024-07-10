<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 3.0.1-rc3 |
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | 0.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.1 |
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 3.0.1-rc3 |
| <a name="provider_talos"></a> [talos](#provider\_talos) | 0.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.talosconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [proxmox_vm_qemu.nodes](https://registry.terraform.io/providers/Telmate/proxmox/3.0.1-rc3/docs/resources/vm_qemu) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_configuration_apply.worker](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/resources/machine_secrets) | resource |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/client_configuration) | data source |
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/cluster_kubeconfig) | data source |
| [talos_machine_configuration.controlplane](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/machine_configuration) | data source |
| [talos_machine_configuration.worker](https://registry.terraform.io/providers/siderolabs/talos/0.5.0/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr"></a> [cidr](#input\_cidr) | n/a | `number` | n/a | yes |
| <a name="input_cluster_endpoint_ip"></a> [cluster\_endpoint\_ip](#input\_cluster\_endpoint\_ip) | n/a | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `string` | n/a | yes |
| <a name="input_extra_manifests"></a> [extra\_manifests](#input\_extra\_manifests) | n/a | `list(string)` | `[]` | no |
| <a name="input_gateway"></a> [gateway](#input\_gateway) | n/a | `string` | n/a | yes |
| <a name="input_install_disk"></a> [install\_disk](#input\_install\_disk) | n/a | `string` | `"/dev/sda"` | no |
| <a name="input_ip_base"></a> [ip\_base](#input\_ip\_base) | n/a | `string` | n/a | yes |
| <a name="input_nameservers"></a> [nameservers](#input\_nameservers) | n/a | `list(string)` | `[]` | no |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | n/a | <pre>map(object({<br>    name             = string<br>    cpu_sockets      = number<br>    cpu_cores        = number<br>    memory           = number<br>    target_node_name = string<br>    disk_size        = string<br>    macaddr          = string<br><br>    controlplane = optional(bool, false)<br>  }))</pre> | n/a | yes |
| <a name="input_proxmox_image"></a> [proxmox\_image](#input\_proxmox\_image) | ################################################## \_\_\_\_\_\_\_\_\_\_\_\_ \_\_\_\_\_\_\_   \_\_\_\_\_  \_\_\_\_\_\_\_\_\_\_   \_\_  # \| \_\_\_ \ \_\_\_ \  \_  \ \ / /\|  \/  \|  \_  \ \ / /  # \| \|\_/ / \|\_/ / \| \| \|\ V / \| .  . \| \| \| \|\ V /   # \|  \_\_/\|    /\| \| \| \|/   \ \| \|\/\| \| \| \| \|/   \   # \| \|   \| \|\ \\ \\_/ / /^\ \\| \|  \| \ \\_/ / /^\ \  # \\_\|   \\_\| \\_\|\\_\_\_/\/   \/\\_\|  \|\_/\\_\_\_/\/   \/  # # ################################################## | `string` | `"local:iso/talos-metal-qemu-1.7.5.iso"` | no |
| <a name="input_proxmox_storage"></a> [proxmox\_storage](#input\_proxmox\_storage) | n/a | `string` | `"local-zfs"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_ipv4_addresses"></a> [vm\_ipv4\_addresses](#output\_vm\_ipv4\_addresses) | n/a |
<!-- END_TF_DOCS -->