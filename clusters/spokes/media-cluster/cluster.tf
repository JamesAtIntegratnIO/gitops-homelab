module "cluster" {
  source = "../../../modules/cluster"

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

}


module "cloudflare" {
  source = "../../../modules/cloudflare"

  cloudflare_zone_name = var.cloudflare_zone_name
  cloudflare_records = {
    "media-cluster" = {
      name    = "media-cluster.integratn.tech"
      type    = "A"
      value   = "10.0.3.200"
      proxied = false
      ttl     = 1
    }
    "star.media-cluster" = {
      name    = "*.media-cluster.integratn.tech"
      type    = "A"
      value   = "10.0.3.200"
      proxied = false
      ttl     = 1
    }
  }
}

data "terraform_remote_state" "hub" {
  backend = "local"

  config = {
    path = "../../hub/terraform.tfstate"
  }
}



# add --var skip_cluster_wait=true to skip the wait if the cluster is already up
resource "time_sleep" "wait_for_cluster" {
  count           = var.skip_cluster_wait ? 0 : 1
  depends_on      = [module.cluster]
  create_duration = "5m"
}

locals {
  gitops_addons_url      = "${var.gitops_addons_org}/${var.gitops_addons_repo}"
  gitops_addons_basepath = var.gitops_addons_basepath
  gitops_addons_path     = var.gitops_addons_path
  gitops_addons_revision = var.gitops_addons_revision

  addons_metadata = merge(
    {
      addons_repo_url      = local.gitops_addons_url
      addons_repo_basepath = local.gitops_addons_basepath
      addons_repo_path     = local.gitops_addons_path
      addons_repo_revision = local.gitops_addons_revision
    },
    {
      external_dns_namespace                    = "external-dns"
      cert_manager_namespace                    = "cert-manager"
      nfs_subdir_external_provisioner_namespace = "nfs-provisioner"
    }
  )

  addons = {
    enable_argon_cd                        = true
    enable_ingress_nginx                   = true
    enable_metallb                         = true
    enable_op_connect                      = true
    enable_external_dns                    = true
    enable_cert_manager                    = true
    enable_nfs_subdir_external_provisioner = true

  }

}

module "argocd" {
  source = "git@github.com:jamesAtIntegratnIO/terraform-helm-gitops-bridge?ref=homelab"

  providers = {
    kubernetes = kubernetes.hub
  }

  install = false
  cluster = {
    cluster_name = var.cluster_name
    environment  = "prod"
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



  depends_on = [time_sleep.wait_for_cluster, kubernetes_secret.onepassword_token]
}