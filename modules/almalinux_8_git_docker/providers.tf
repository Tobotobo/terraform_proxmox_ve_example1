terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

provider "proxmox" {
  pm_user        = "${var.pm_user}"
  pm_password    = "terraform"
  pm_api_url     = "http://XXXXX:8006/api2/json"
  pm_tls_insecure = true
}