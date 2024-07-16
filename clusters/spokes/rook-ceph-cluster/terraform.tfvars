nodes = {
  "10.0.5.101" = {
    name             = "rook-ceph-1"
    create_vm    = false
    controlplane     = true
  }
  "10.0.5.102" = {
    name             = "rook-ceph-2"
    create_vm    = false
    controlplane     = true
  }
  "10.0.5.103" = {
    name             = "rook-ceph-3"
    create_vm    = false
    controlplane     = true
  }
}

ip_base             = "10.0.5.0"
cidr                = 9
gateway             = "10.0.0.1"
cluster_endpoint_ip = "10.0.5.100"
nameservers         = ["192.168.16.53", "10.0.0.1"]

cluster_name = "rook-ceph-cluster"

extra_manifests = [
  "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml",
  "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
]

allow_scheduling_on_controlplane = true

gitops_workload_basepath = ""
gitops_workload_path     = "workloads"
gitops_workload_revision = "main"
gitops_workload_repo     = "gitops-rook-ceph-cluster.git"
gitops_workload_org      = "git@github.com:JamesAtIntegratnIO"