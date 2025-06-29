terraform {
  backend "pg" {
    conn_str = "postgres://10.0.3.1/terraform_media_cluster"
  }
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc4"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.8.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.10.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.39.0"
    }
    onepassword = {
      source  = "1Password/onepassword"
      version = ">= 2.1.2"
    }

  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.0.10:8006/api2/json"
  # set PM_USER and PM_PASS in your environment
}

provider "talos" {}

provider "kubernetes" {
  host                   = module.cluster.kubeconfig.kubernetes_client_configuration.host
  cluster_ca_certificate = base64decode(module.cluster.kubeconfig.kubernetes_client_configuration.ca_certificate)
  client_key             = base64decode(module.cluster.kubeconfig.kubernetes_client_configuration.client_key)
  client_certificate     = base64decode(module.cluster.kubeconfig.kubernetes_client_configuration.client_certificate)

}

provider "kubernetes" {
  alias = "hub"

  host                   = data.terraform_remote_state.hub.outputs.kubeconfig.kubernetes_client_configuration.host
  cluster_ca_certificate = base64decode(data.terraform_remote_state.hub.outputs.kubeconfig.kubernetes_client_configuration.ca_certificate)
  client_key             = base64decode(data.terraform_remote_state.hub.outputs.kubeconfig.kubernetes_client_configuration.client_key)
  client_certificate     = base64decode(data.terraform_remote_state.hub.outputs.kubeconfig.kubernetes_client_configuration.client_certificate)
}

provider "helm" {
  kubernetes {
    config_path    = "./kubeconfig"
    config_context = join("@", ["admin", var.cluster_name])
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_key
}

provider "onepassword" {
  url                   = "https://connect.integratn.tech"
  token                 = var.onepassword_token
}