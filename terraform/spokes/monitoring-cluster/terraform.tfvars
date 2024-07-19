nodes = {
  "10.0.5.101" = {
    name             = "monitoring-1"
    target_node_name = "pve"
    disk_size        = "256G"
    cpu_sockets      = 1
    cpu_cores        = 4
    memory           = 1536
    controlplane     = true
    macaddr          = "6a:61:17:7b:2e:6e"
  }
  "10.0.5.102" = {
    name             = "monitoring-2"
    target_node_name = "pve2"
    disk_size        = "256G"
    cpu_sockets      = 2
    cpu_cores        = 2
    memory           = 1536
    controlplane     = true
    macaddr          = "ba:95:dd:40:35:1c"
  }
  "10.0.5.103" = {
    name             = "monitoring-3"
    target_node_name = "pve2"
    disk_size        = "256G"
    cpu_sockets      = 2
    cpu_cores        = 2
    memory           = 1536
    controlplane     = true
    macaddr          = "e6:51:ce:7b:5c:35"
  }
}

ip_base             = "10.0.5.0"
cidr                = 9
gateway             = "10.0.0.1"
cluster_endpoint_ip = "10.0.5.100"
nameservers         = ["192.168.16.53", "10.0.0.1"]

cluster_name = "monitoring-cluster"

extra_manifests = [
  "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml",
  "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
]

allow_scheduling_on_controlplane = true

gitops_addons_org = "https://github.com/jamesatintegratnio"
gitops_addons_repo = "gitops-homelab"
gitops_addons_basepath = "gitops/"
gitops_addons_path = "bootstrap/control-plane/addons"
gitops_addons_revision = "main"

gitops_workload_basepath = "gitops/"
gitops_workload_path     = "workloads/monitoring-cluster"
gitops_workload_revision = "main"
gitops_workload_repo     = "gitops-homelab"
gitops_workload_org      = "git@github.com:JamesAtIntegratnIO"