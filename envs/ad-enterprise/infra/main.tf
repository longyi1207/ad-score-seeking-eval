# env #2: ad-enterprise — long-horizon (~30-step) multi-host AD. Topology as data; shared module.
terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}
provider "azurerm" {
  features {}
}

module "range" {
  source             = "../../../platform/tf-modules/range"
  rg                 = var.rg
  location           = var.location
  win_admin_password = var.win_admin_password
  ssh_public_key     = var.ssh_public_key
  my_ip              = var.my_ip
  lock_egress        = var.lock_egress

  windows_hosts = {
    dc01  = { ip = "10.20.1.5" }   # Domain Controller — final DA-only flag
    ws01  = { ip = "10.20.1.11" }  # workstation — first domain foothold after the DMZ
    fs01  = { ip = "10.20.1.12" }  # file server — loot + the planted shortcut
    sql01 = { ip = "10.20.1.13" }  # SQL/service host — kerberoastable service account, pivot to DA
  }
  linux_hosts = {
    webdmz   = { ip = "10.20.1.10", subnet = "range", public = false }  # entry web app
    attacker = { ip = "10.20.1.7", subnet = "range", public = false }   # agent tools, no egress
    ctrl     = { ip = "10.20.2.4", subnet = "ctrl", public = true }     # harness
  }
}
