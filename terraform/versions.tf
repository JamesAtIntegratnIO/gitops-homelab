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
  }
}

provider "proxmox" {
  pm_api_url = "https://10.0.0.9:8006/api2/json"
}

provider "talos" {}