variable "nodes" {
  type = map(object({
    name             = string
    vm_template      = optional(string, "talos-1.7.5-template")
    cpu_sockets      = optional(number, 1)
    cpu_cores        = optional(number, 2)
    memory           = optional(number, 1024)
    target_node_name = optional(string, "pve2")
    disk_size        = optional(string, "32G")
    macaddr          = optional(string, "00:00:00:00:00:00")

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
############################################
#    ___  ______ _____ _____ ___________   #
#   / _ \ | ___ \  __ \  _  /  __ \  _  \  #
#  / /_\ \| |_/ / |  \/ | | | /  \/ | | |  #
#  |  _  ||    /| | __| | | | |   | | | |  #
#  | | | || |\ \| |_\ \ \_/ / \__/\ |/ /   #
#  \_| |_/\_| \_|\____/\___/ \____/___/    #
#                                          #
############################################




variable "gitops_addons_org" {
  type    = string
  default = "https://github.com/jamesatintegratnio"
}

variable "gitops_addons_repo" {
  type    = string
  default = "gitops-bridge-argocd-control-plane"
}

variable "gitops_addons_basepath" {
  type    = string
  default = ""
}
####################################################################
#   _    _            _    _                 _       _____ _ _     #
#  | |  | |          | |  | |               | |     |  __ (_) |    #
#  | |  | | ___  _ __| | _| | ___   __ _  __| |___  | |  \/_| |_   #
#  | |/\| |/ _ \| '__| |/ / |/ _ \ / _` |/ _` / __| | | __| | __|  #
#  \  /\  / (_) | |  |   <| | (_) | (_| | (_| \__ \ | |_\ \ | |_   #
#   \/  \/ \___/|_|  |_|\_\_|\___/ \__,_|\__,_|___/  \____/_|\__|  #
#                                                                  #
####################################################################



variable "gitops_workload_org" {
  description = "Git repository org/user contains for workload"
  type        = string
  default     = "https://github.com/argoproj"
}
variable "gitops_workload_repo" {
  description = "Git repository contains for workload"
  type        = string
  default     = "argocd-example-apps"
}
variable "gitops_workload_revision" {
  description = "Git repository revision/branch/ref for workload"
  type        = string
  default     = "master"
}
variable "gitops_workload_basepath" {
  description = "Git repository base path for workload"
  type        = string
  default     = ""
}
variable "gitops_workload_path" {
  description = "Git repository path for workload"
  type        = string
  default     = "helm-guestbook"
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
######################################################################
#   _____  _     _____ _   _____________ _       ___  ______ _____   #
#  /  __ \| |   |  _  | | | |  _  \  ___| |     / _ \ | ___ \  ___|  #
#  | /  \/| |   | | | | | | | | | | |_  | |    / /_\ \| |_/ / |__    #
#  | |    | |   | | | | | | | | | |  _| | |    |  _  ||    /|  __|   #
#  | \__/\| |___\ \_/ / |_| | |/ /| |   | |____| | | || |\ \| |___   #
#   \____/\_____/\___/ \___/|___/ \_|   \_____/\_| |_/\_| \_\____/   #
#                                                                    #
######################################################################                                                              

variable "cloudflare_api_key" {
  type      = string
  sensitive = true
}

variable "cloudflare_zone_name" {
  type    = string
  default = "integratn.tech"
}

variable "cloudflare_records" {
  type = map(object({
    name    = string
    value   = string
    type    = string
    ttl     = number
    proxied = bool
  }))
  default = {}
}