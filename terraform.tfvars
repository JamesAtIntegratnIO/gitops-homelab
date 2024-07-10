nodes = {
  "10.0.4.101" = {
    name             = "talos-cp-1"
    target_node_name = "pve2"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 2
    memory           = 4096
    controlplane     = true
    macaddr          = "0a:bc:b0:fc:95:d7"
  }
  "10.0.4.102" = {
    name             = "talos-cp-2"
    target_node_name = "pve2"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 2
    memory           = 4096
    controlplane     = true
    macaddr          = "da:e2:ee:31:02:6e"
  }
  "10.0.4.103" = {
    name             = "talos-cp-3"
    target_node_name = "pve2"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 2
    memory           = 4096
    controlplane     = true
    macaddr          = "7e:08:b4:f9:3b:5e"
  }
  "10.0.4.104" = {
    name             = "talows-w-1"
    target_node_name = "pve2"
    disk_size        = "32G"
    cpu_sockets      = 2
    cpu_cores        = 4
    memory           = 8192
    macaddr          = "1e:b8:d6:c6:f9:85"
  }
  "10.0.4.105" = {
    name             = "talows-w-2"
    target_node_name = "pve2"
    disk_size        = "32G"
    cpu_sockets      = 2
    cpu_cores        = 4
    memory           = 8192
    macaddr          = "ee:8b:b0:43:78:9a"
  }
  "10.0.4.106" = {
    name             = "talows-w-3"
    target_node_name = "pve2"
    disk_size        = "32G"
    cpu_sockets      = 2
    cpu_cores        = 4
    memory           = 8192
    macaddr          = "0e:c0:fe:f9:87:07"
  }
}

ip_base             = "10.0.4.0"
cidr                = 9
gateway             = "10.0.0.1"
cluster_endpoint_ip = "10.0.4.100"
nameservers = [ "192.168.16.53", "10.0.0.1" ]

proxmox_image   = "local:iso/talos-metal-qemu-1.7.5.iso"
proxmox_storage = "local-zfs"

cluster_name = "get-rekt-talos"

extra_manifests = [
  "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml",
  "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
]