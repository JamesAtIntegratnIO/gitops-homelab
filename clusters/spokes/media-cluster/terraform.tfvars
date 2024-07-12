nodes = {
  "10.0.3.101" = {
    name         = "pi-cluster-1"
    create_vm    = false
    controlplane = true
  }
  "10.0.3.102" = {
    name         = "pi-cluster-2"
    create_vm    = false
    controlplane = true
  }
  "10.0.3.103" = {
    name         = "pi-cluster-3"
    create_vm    = false
    controlplane = true
  }
  "10.0.3.104" = {
    name      = "pi-cluster-4"
    create_vm = false
  }
  "10.0.3.105" = {
    name      = "pi-cluster-5"
    create_vm = false
  }
}

ip_base             = "10.0.3.0"
cidr                = 9
gateway             = "10.0.0.1"
cluster_endpoint_ip = "10.0.3.100"
nameservers         = ["192.168.16.53", "10.0.0.1"]

cluster_name = "media-cluster"

extra_manifests = [
  "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml",
  "https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
]
