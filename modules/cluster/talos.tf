resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.cluster_endpoint_ip}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.cluster_endpoint_ip}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in var.nodes : k if v.controlplane == true]
}


resource "talos_machine_configuration_apply" "controlplane" {
  for_each = { for k, v in var.nodes : k => v if v.controlplane == true }

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration

  node = each.key
  config_patches = [
    templatefile("${path.module}/templates/controlplane-machine.yaml.tmpl", {
      hostname        = each.value.name
      cert_sans       = [var.cluster_endpoint_ip]
      vip             = var.cluster_endpoint_ip
      ip_address      = each.key
      cidr            = var.cidr
      gateway         = var.gateway
      nameservers     = var.nameservers
      disk            = var.install_disk
      extra_manifests = var.extra_manifests
    }),
  ]

  depends_on = [proxmox_vm_qemu.nodes]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = { for k, v in var.nodes : k => v if v.controlplane != true }

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/templates/worker-machine.yaml.tmpl", {
      hostname    = each.value.name
      cert_sans   = [var.cluster_endpoint_ip]
      ip_address  = each.key
      cidr        = var.cidr
      gateway     = var.gateway
      nameservers = var.nameservers
      disk        = var.install_disk
    }),
  ]
  depends_on = [proxmox_vm_qemu.nodes]

}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.nodes : k if v.controlplane == true][0]
}

resource "local_file" "talosconfig" {
  content  = data.talos_client_configuration.this.talos_config
  filename = "${path.root}/talosconfig"
}

data "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.nodes : k if v.controlplane == true][0]
  timeouts = {
    read = "30m"
  }
}

resource "local_file" "kubeconfig" {
  content  = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  filename = "${path.root}/kubeconfig"

  lifecycle {
    ignore_changes = [content]
  }
}