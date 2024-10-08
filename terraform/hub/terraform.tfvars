nodes = {
  "10.0.4.101" = {
    name             = "talos-cp-1"
    target_node_name = "pve2"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 2
    memory           = 6144
    controlplane     = true
    networks = [
      {
      macaddr          = "0a:bc:b0:fc:95:d7"
      vlan             = 25
      },
    ]
  }
  "10.0.4.102" = {
    name             = "talos-cp-2"
    target_node_name = "pve"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 2
    memory           = 6144
    controlplane     = true
    networks = [
      {
      macaddr          = "da:e2:ee:31:02:6e"
      vlan             = 25
      },
    ]
    
  }
  "10.0.4.103" = {
    name             = "talos-cp-3"
    target_node_name = "pve"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 2
    memory           = 6192
    controlplane     = true
    networks = [
      {
      macaddr          = "7e:08:b4:f9:3b:5e"
      vlan             = 25
      },
    ]
  }
  "10.0.4.104" = {
    name             = "talos-w-1"
    target_node_name = "pve2"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 4
    memory           = 8192
    networks = [
      {
      macaddr          = "1e:b8:d6:c6:f9:85"
      vlan             = 25
      },
    ]
  }
  "10.0.4.105" = {
    name             = "talos-w-2"
    target_node_name = "pve2"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 4
    memory           = 8192
    networks = [
      {
      macaddr          = "ee:8b:b0:43:78:9a"
      vlan             = 25
      },
    ]
  }
  "10.0.4.106" = {
    name             = "talos-w-3"
    target_node_name = "pve"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 4
    memory           = 8192
    networks = [
      {
      macaddr          = "0e:c0:fe:f9:87:07"
      vlan             = 25
      },
    ]
  }
}

ip_base             = "10.0.4.0"
cidr                = 9
gateway             = "10.0.0.1"
cluster_endpoint_ip = "10.0.4.100"
nameservers         = ["1.1.1.1", "10.0.0.1"]

proxmox_image   = "local:iso/talos-metal-qemu-1.7.5.iso"
proxmox_storage = "local-zfs"

cluster_name = "controlplane-cluster"
allow_scheduling_on_controlplane = true

gitops_addons_org = "https://github.com/jamesatintegratnio"
gitops_addons_repo = "gitops-homelab"
gitops_addons_basepath = "gitops/"
gitops_addons_path = "bootstrap/control-plane/addons"
gitops_addons_revision = "main"

extra_manifests = [
  "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml",
  "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
]

cloudflare_zone_name = "integratn.tech"

cloudflare_records = {
  "controlplane" = {
    name    = "controlplane.integratn.tech"
    content   = "10.0.4.200"
    type    = "A"
    ttl     = 1
    proxied = false
  }
  "star.controlplane" = {
    name    = "*.controlplane.integratn.tech"
    content   = "10.0.4.200"
    type    = "A"
    ttl     = 1
    proxied = false
  }
}