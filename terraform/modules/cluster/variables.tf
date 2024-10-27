variable "nodes" {
  type = map(object({
    name             = string
    vm_template      = optional(string, "talos-1.7.5-template" )
    cpu_sockets      = optional(number, 1)
    cpu_cores        = optional(number, 2)
    memory           = optional(number, 1024)
    target_node_name = optional(string, "pve2")
    disk_size        = optional(string, "32G")
    emulatessd       = optional(bool, true)
    disk_cache       = optional(string, "unsafe")
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
  default = "talos-1.7.5-template"
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

variable "disk_cache" {
  type    = string
  default = "unsafe"
}

variable "emulatessd" {
  type    = bool
  default = true
}

variable "tags" {
  type    = list(string)
  default = []
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