nodes = {
  "10.0.5.101" = {
    name             = "talos-controlplane-1"
    create_vm        = false
    controlplane     = true
    networks = [
      {
      vlan             = 25
      },
    ]
  }
  "10.0.5.102" = {
    name             = "talos-controlplane-2"
    create_vm        = false
    controlplane     = true
    networks = [
      {
      vlan             = 25
      },
    ]
    
  }
  "10.0.5.103" = {
    name             = "talos-controlplane-3"
    create_vm        = false
    controlplane     = true
    networks = [
      {
      vlan             = 25
      },
    ]
  }
}

ip_base             = "10.0.5.0"
cidr                = 9
gateway             = "10.0.0.1"
cluster_endpoint_ip = "10.0.5.100"
nameservers         = ["1.1.1.1", "10.0.0.1"]


cluster_name = "cp-cluster"
allow_scheduling_on_controlplane = true

install_disk = "/dev/nvme0n1"

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
    content   = "10.0.5.200"
    type    = "A"
    ttl     = 1
    proxied = false
  }
  "star.controlplane" = {
    name    = "*.controlplane.integratn.tech"
    content   = "10.0.5.200"
    type    = "A"
    ttl     = 1
    proxied = false
  }
}