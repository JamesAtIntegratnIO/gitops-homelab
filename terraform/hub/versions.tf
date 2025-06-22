terraform {
  backend "pg" {
    conn_str = "postgres://10.0.3.1/terraform_state"
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
  config_path    = "./kubeconfig"
  config_context = join("@", ["admin", var.cluster_name])
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