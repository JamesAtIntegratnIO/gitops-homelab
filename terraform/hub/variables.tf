variable "nodes" {
  type = map(object({
    name             = string
    vm_template      = optional(string, "talos-1.8.1-template" )
    cpu_sockets      = optional(number, 1)
    cpu_cores        = optional(number, 2)
    memory           = optional(number, 1024)
    target_node_name = optional(string, "pve2")
    disk_size        = optional(string, "32G")
    # add a list of network objects
    networks         = optional(list(object({
      model    = optional(string, "virtio")
      bridge   = optional(string, "vmbr0")
      firewall = optional(bool, false)
      vlan     = optional(string, "-1")
      macaddr  = optional(string, null)
    })))

    controlplane = optional(bool, false)
    create_vm    = optional(bool, true)
    nvidia       = optional(bool, false)
  }))
}
###################################################
#  ____________ _______   _____  __________   __  #
#  | ___ \ ___ \  _  \ \ / /|  \/  |  _  \ \ / /  #
#  | |_/ / |_/ / | | |\ V / | .  . | | | |\ V /   #
#  |  __/|    /| | | |/   \ | |\/| | | | |/   \   #
#  | |   | |\ \\ \_/ / /^\ \| |  | \ \_/ / /^\ \  #
#  \_|   \_| \_|\___/\/   \/\_|  |_/\___/\/   \/  #
#                                                 #                                          
###################################################
variable "proxmox_image" {
  type    = string
  default = "local:iso/talos-metal-qemu-1.7.5.iso"
}

variable "vm_template" {
  type    = string
  default = "talos-1.8.1-template"
}

variable "ip_base" {
  type = string
}

variable "cidr" {
  type = number
}

variable "gateway" {
  type = string
}

variable "proxmox_storage" {
  type    = string
  default = "local-zfs"

}
#####################################
#   _____ ___   _     _____ _____   #
#  |_   _/ _ \ | |   |  _  /  ___|  #
#    | |/ /_\ \| |   | | | \ `--.   #
#    | ||  _  || |   | | | |`--. \  #
#    | || | | || |___\ \_/ /\__/ /  #
#    \_/\_| |_/\_____/\___/\____/   #
#                                   #                                          
#####################################

variable "cluster_name" {
  type = string
}

variable "cluster_endpoint_ip" {
  type = string
}

variable "nameservers" {
  type    = list(string)
  default = []
}

variable "install_disk" {
  type    = string
  default = "/dev/sda"
}

variable "extra_manifests" {
  type    = list(string)
  default = []
}

variable "allow_scheduling_on_controlplane" {
  type    = bool
  default = false
}

# ARGOCD

variable "gitops_addons_org" {
  type    = string
  default = "https://github.com/jamesatintegratnio"
}

variable "gitops_addons_repo" {
  type    = string
  default = "gitops-homelab"
}

variable "gitops_addons_basepath" {
  type    = string
  default = "gitops"
}

variable "gitops_addons_path" {
  type    = string
  default = "bootstrap/control-plane/addons"
}

variable "gitops_addons_revision" {
  type    = string
  default = "homelab"
}

variable "skip_cluster_wait" {
  type    = bool
  default = false
}

variable "onepassword_credentials" {
  type        = string
  sensitive   = true
  description = "base64 encoded 1password credentials"
}

variable "onepassword_token" {
  type      = string
  sensitive = true
}

# cloudflare

variable "cloudflare_api_key" {
  type      = string
  sensitive = true
}

variable "cloudflare_zone_name" {
  type = string
}

variable "cloudflare_records" {
  type = map(object({
    name    = string
    content   = string
    type    = string
    ttl     = number
    proxied = bool
  }))
}