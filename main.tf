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

module "cloudflare" {
  source = "./modules/cloudflare"
  
  cloudflare_zone_name = var.cloudflare_zone_name
  cloudflare_records = var.cloudflare_records
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
    },
    {
      external_dns_namespace = "external-dns"
      cert_manager_namespace = "cert-manager"
    }
  )
}

# add --var skip_cluster_wait=true to skip the wait if the cluster is already up
resource "time_sleep" "wait_for_cluster" {
  count = var.skip_cluster_wait ? 0 : 1
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
      enable_op_connect = true
      enable_external_dns = true
      enable_cert_manager = true
    }
  }
  apps = {
    addons = file("${path.module}/bootstrap/addons.yaml")
    }

  depends_on = [ time_sleep.wait_for_cluster ]
}

resource "kubernetes_namespace" "op_connect" {
  metadata {
    annotations = {
      name = "op-connect"
    }
    name = "op-connect"
  }
  depends_on = [ time_sleep.wait_for_cluster ]
}

resource "kubernetes_secret" "op_credentials" {
  metadata {
    name = "op-credentials"
    namespace = kubernetes_namespace.op_connect.metadata.0.name
  }
  data = {
    "1password-credentials.json" = var.onepassword_credentials
  }
  depends_on = [ kubernetes_namespace.op_connect ]
}

resource "kubernetes_secret" "onepassword_token" {
  metadata {
    name = "onepassword-token"
    namespace = kubernetes_namespace.op_connect.metadata.0.name
  }
  data = {
    token = var.onepassword_token
  }
  depends_on = [ kubernetes_namespace.op_connect ]
}

resource "kubernetes_secret" "docker-config" {
  metadata {
    name = "ghcr-login-secret"
    namespace = "argocd"
  }

  data = {
    ".dockerconfigjson" = "${file("${path.module}/dockerconfig.json")}"
  }

  type = "kubernetes.io/dockerconfigjson"

  depends_on = [ module.argocd ]
}