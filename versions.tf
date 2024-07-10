terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.5.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.1"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://10.0.0.9:8006/api2/json"
}

provider "talos" {}

provider "kubernetes" {
  config_path = "./kubeconfig"
  config_context = join("@", ["admin", var.cluster_name])
}

provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
    config_context = join("@", ["admin", var.cluster_name])
  }
}