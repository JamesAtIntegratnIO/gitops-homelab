nodes = {
  "10.0.6.101" = {
    name         = "k0s-media-worker1"
    create_vm    = false
    controlplane = true
    networks = [{
      vlan = 25
    }]
  }
  "10.0.6.102" = {
    name         = "k0s-media-worker2"
    create_vm    = false
    controlplane = true
    networks = [{
      vlan = 25
    }]
  }

}

ip_base             = "10.0.6.0"
cidr                = 9
gateway             = "10.0.0.1"
cluster_endpoint_ip = "10.0.6.100"
nameservers         = ["1.1.1.1", "10.0.0.1"]

cluster_name = "media-cluster"

extra_manifests = [
  "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml"
]

gitops_addons_org = "https://github.com/jamesatintegratnio"
gitops_addons_repo = "gitops-homelab"
gitops_addons_basepath = "gitops/"
gitops_addons_path = "bootstrap/control-plane/addons"
gitops_addons_revision = "main"

gitops_workload_basepath = ""
gitops_workload_path     = "workloads"
gitops_workload_revision = "main"
gitops_workload_repo     = "gitops-homelab-private.git"
gitops_workload_org      = "git@github.com:JamesAtIntegratnIO"