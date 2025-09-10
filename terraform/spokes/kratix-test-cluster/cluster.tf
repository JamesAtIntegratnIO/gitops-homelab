module "cluster" {
  source = "../../modules/cluster"

  nodes               = var.nodes
  ip_base             = var.ip_base
  cidr                = var.cidr
  gateway             = var.gateway
  cluster_endpoint_ip = var.cluster_endpoint_ip
  nameservers         = var.nameservers
  proxmox_image       = var.proxmox_image
  proxmox_storage     = var.proxmox_storage
  cluster_name        = var.cluster_name
  extra_manifests     = var.extra_manifests
  
  allow_scheduling_on_controlplane = true

}


module "cloudflare" {
  source = "../../modules/cloudflare"

  cloudflare_zone_name = var.cloudflare_zone_name
  cloudflare_records = {
    "media-cluster" = {
      name    = "media-cluster.integratn.tech"
      type    = "A"
      content   = "10.0.3.200"
      proxied = false
      ttl     = 1
    }
    "star.media-cluster" = {
      name    = "*.media-cluster.integratn.tech"
      type    = "A"
      content   = "10.0.3.200"
      proxied = false
      ttl     = 1
    }
  }
}

data "terraform_remote_state" "hub" {
  backend = "pg"
  config = {
    conn_str = "postgres://10.0.3.1/terraform_state"
  }
}



# add --var skip_cluster_wait=true to skip the wait if the cluster is already up
resource "time_sleep" "wait_for_cluster" {
  count           = var.skip_cluster_wait ? 0 : 1
  depends_on      = [module.cluster]
  create_duration = "5m"
}

locals {
  name        = module.cluster.cluster_name
  environment = "prod"

  gitops_addons_url      = "${var.gitops_addons_org}/${var.gitops_addons_repo}"
  gitops_addons_basepath = var.gitops_addons_basepath
  gitops_addons_path     = var.gitops_addons_path
  gitops_addons_revision = var.gitops_addons_revision

  gitops_workload_org      = var.gitops_workload_org
  gitops_workload_repo     = var.gitops_workload_repo
  gitops_workload_basepath = var.gitops_workload_basepath
  gitops_workload_path     = var.gitops_workload_path
  gitops_workload_revision = var.gitops_workload_revision
  gitops_workload_url      = "${local.gitops_workload_org}/${local.gitops_workload_repo}"

  addons_metadata = merge(
    {
      addons_repo_url      = local.gitops_addons_url
      addons_repo_basepath = local.gitops_addons_basepath
      addons_repo_path     = local.gitops_addons_path
      addons_repo_revision = local.gitops_addons_revision
      managed-by           = "argocd.argoproj.io"
    },
    {
      external_dns_namespace                    = "external-dns"
      cert_manager_namespace                    = "cert-manager"
      nfs_subdir_external_provisioner_namespace = "nfs-provisioner"
    },
  )

  workloads_metadata = merge(
    {
      cluster_name = local.name
    },
    {
      workload_repo_url      = local.gitops_workload_url
      workload_repo_basepath = local.gitops_workload_basepath
      workload_repo_path     = local.gitops_workload_path
      workload_repo_revision = local.gitops_workload_revision
    },
  )

  addons = merge(
    {
      enable_argocd                          = true
      enable_argocd_image_updater            = true
      enable_ingress_nginx                   = true
      enable_metallb                         = true
      enable_external_dns                    = true
      enable_cert_manager                    = true
      enable_nfs_subdir_external_provisioner = true
      enable_stakater_reloader               = true
      enable_kube_prometheus_stack           = true
      enable_headlamp                        = true
      enable_external_secrets                = true
    },
  )
}

module "hub_cluster" {
  source = "git@github.com:jamesAtIntegratnIO/terraform-helm-gitops-bridge?ref=homelab"

  providers = {
    kubernetes = kubernetes.hub
  }

  install = false
  cluster = {
    cluster_name = local.name
    environment  = local.environment
    metadata     = local.addons_metadata

    addons = local.addons


    server = "https://${var.cluster_endpoint_ip}:6443"
    config = <<-EOT
       {
        "tlsClientConfig": {
          "insecure": false,
          "caData" : "${module.cluster.kubeconfig.kubernetes_client_configuration.ca_certificate}",
          "certData" : "${module.cluster.kubeconfig.kubernetes_client_configuration.client_certificate}",
          "keyData" : "${module.cluster.kubeconfig.kubernetes_client_configuration.client_key}"
        }
      }
    EOT
  }

  depends_on = [time_sleep.wait_for_cluster]
}

module "spoke_cluster" {
  source = "git@github.com:jamesAtIntegratnIO/terraform-helm-gitops-bridge?ref=homelab"

  providers = {
    kubernetes = kubernetes
  }

  install = false # Not installing argocd via helm on spoke cluster as it is installed by the hub cluster addons
  cluster = {
    cluster_name = local.name
    environment  = local.environment
    metadata     = local.workloads_metadata
    addons = {
      enable_argocd = false # ArgoCD is deployed from Hub Cluster
    }
  }
  apps = {
    workloads = file("${path.module}/bootstrap/workloads.yaml")
  }
  

  depends_on = [time_sleep.wait_for_cluster]
}


resource "kubernetes_secret" "docker-config" {
  provider = kubernetes
  metadata {
    name      = "ghcr-login-secret"
    namespace = "argocd"
  }

  data = {
    ".dockerconfigjson" = "${file("${path.module}/dockerconfig.json")}"
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = [module.hub_cluster]
}

# resource "kubernetes_manifest" "nvidia_runtimeclass" {
#   provider = kubernetes
#   manifest = {
#     apiVersion = "node.k8s.io/v1"
#     kind       = "RuntimeClass"
#     metadata = {
#       name = "nvidia"
#     }
#     handler = "nvidia"
#   }

#   depends_on = [module.spoke_cluster]
# }

# resource "kubernetes_node_taint" "nvidia_gpu_true" {
#   provider = kubernetes
#   for_each = { for key, value in var.nodes : key => value if lookup(value, "nvidia", false) == true }

#   metadata {
#     name = each.value.name
#   }

#   taint {
#     key    = "nvidia.com/gpu"
#     value  = "true"
#     effect = "NoSchedule"
#   }

#   depends_on = [module.spoke_cluster]
# }

# resource "kubernetes_node_taint" "nvidia_gpu" {
#   for_each = { for key, value in var.nodes : key => value if lookup(value, "nvidia", false) == true }

#   metadata {
#     name = each.value.name
#   }

#   taint {
#     key    = "nvidia.com/gpu"
#     value  = ""
#     effect = "NoSchedule"
#   }

#   depends_on = [module.spoke_cluster]
# }


# resource "kubernetes_node_taint" "nvidia_gpu_present" {
#   provider = kubernetes
#   for_each = { for key, value in var.nodes : key => value if lookup(value, "nvidia", false) == true }

#   metadata {
#     name = each.value.name
#   }

#   taint {
#     key    = "nvidia.com/gpu"
#     value  = "present"
#     effect = "NoSchedule"
#   }

#   depends_on = [module.spoke_cluster]

# }