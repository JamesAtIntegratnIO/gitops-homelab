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

module "argocd" {
  source = "git@github.com:jamesAtIntegratnIO/terraform-helm-gitops-bridge?ref=homelab"

  depends_on = [ module.cluster ]
}