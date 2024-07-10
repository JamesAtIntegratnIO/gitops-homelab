variable "nodes" {
  type = map(object({
    name             = string
    cpu_sockets      = number
    cpu_cores        = number
    memory           = number
    target_node_name = string
    disk_size        = string
    macaddr          = string

    controlplane = optional(bool, false)
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

# ARGOCD

variable "gitops_addons_org" {
  type = string
  default = "https://github.com/jamesatintegratnio"
}

variable "gitops_addons_repo" {
  type = string
  default = "gitops-bridge-argocd-control-plane"
}

variable "gitops_addons_basepath" {
  type = string
  default = ""
}

variable "gitops_addons_path" {
  type = string
  default = "bootstrap/control-plane/addons"
}

variable "gitops_addons_revision" {
  type = string
  default = "homelab"
}
