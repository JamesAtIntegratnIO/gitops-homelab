module "cluster" {
  source = "./modules/cluster"
  
  nodes = var.nodes
  ip_base = var.ip_base
  cidr = var.cidr
  gateway = var.gateway
  cluster_endpoint_ip = var.cluster_endpoint_ip
  nameservers = var.nameservers
  proxmox_image = var.proxmox_image
  proxmox_storage = var.proxmox_storage
  cluster_name = var.cluster_name
  extra_manifests = var.extra_manifests
  
}

locals  {
  gitops_addons_url = "${var.gitops_addons_org}/${var.gitops_addons_repo}"
  gitops_addons_basepath = var.gitops_addons_basepath
  gitops_addons_path     = var.gitops_addons_path
  gitops_addons_revision = var.gitops_addons_revision

  addons_metadata = merge(
    {
      addons_repo_url      = local.gitops_addons_url
      addons_repo_basepath = local.gitops_addons_basepath
      addons_repo_path     = local.gitops_addons_path
      addons_repo_revision = local.gitops_addons_revision
    }
  )
}

resource "time_sleep" "wait_for_cluster" {
  depends_on = [module.cluster]
  create_duration = "7m"
}

module "argocd" {
  source = "git@github.com:jamesAtIntegratnIO/terraform-helm-gitops-bridge?ref=homelab"

  cluster = {
    cluster_name = var.cluster_name
    environment = "prod"
    metadata = local.addons_metadata

    addons = {
      enable_argocd = true
      enable_ingress_nginx = true
      enable_metallb = true
    }
  }
  apps = {
    addons = file("${path.module}/bootstrap/addons.yaml")
    }

  depends_on = [ time_sleep.wait_for_cluster ]
}