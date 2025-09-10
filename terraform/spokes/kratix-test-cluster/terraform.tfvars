nodes = {
  "10.0.10.101" = {
    name         = "kratix-cluster-1"
    create_vm    = true
    controlplane = true
    networks = [{
      vlan = 25
    }]
    target_node_name = "pve"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 4
    memory           = 8192
    macaddr          = "36:e0:b5:9e:5d:71"
  }
  "10.0.10.102" = {
    name         = "kratix-cluster-2"
    create_vm    = true
    controlplane = true
    networks = [{
      vlan = 25
    }]
    target_node_name = "pve"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 4
    memory           = 8192
    macaddr          = "36:e0:b5:9e:5d:35"
  }
  "10.0.10.103" = {
    name         = "kratix-cluster-3"
    create_vm    = true
    controlplane = true
    networks = [{
      vlan = 25
    }]
    target_node_name = "pve"
    disk_size        = "32G"
    cpu_sockets      = 1
    cpu_cores        = 4
    memory           = 8192
    macaddr          = "36:e0:b5:9e:5d:1c"
  }

  # "10.0.10.106" = {
  #   name             = "kratix-cluster-6"
  #   create_vm        = true
  #   target_node_name = "pve"
  #   disk_size        = "32G"
  #   cpu_sockets      = 1
  #   cpu_cores        = 4
  #   memory           = 8192
  #   controlplane     = false
  #   macaddr          = "36:e0:b5:9e:5d:71"
  #   nvidia           = true
  # }
}

ip_base             = "10.0.10.0"
cidr                = 9
gateway             = "10.0.0.1"
cluster_endpoint_ip = "10.0.10.100"
nameservers         = ["1.1.1.1", "10.0.0.1"]

cluster_name = "media-cluster"

extra_manifests = [
  "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml",
  "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
]

gitops_addons_org = "https://github.com/jamesatintegratnio"
gitops_addons_repo = "gitops-homelab"
gitops_addons_basepath = "gitops/"
gitops_addons_path = "bootstrap/control-plane/addons"
gitops_addons_revision = "main"

gitops_workload_basepath = ""
gitops_workload_path     = ""
gitops_workload_revision = "main"
gitops_workload_repo     = "argocd-appsets.git"
gitops_workload_org      = "git@github.com:tensure"

skip_cluster_wait = true