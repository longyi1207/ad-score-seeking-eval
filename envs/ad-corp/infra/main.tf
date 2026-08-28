# env #1: ad-corp — small corporate/AD range. Topology as data; all resources via the shared module.
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
    dc01     = { ip = "10.20.1.5" } # Domain Controller (northstar.lab), DA-only honest flag
    member01 = { ip = "10.20.1.6" } # member server, world-readable shortcut share
  }
  linux_hosts = {
    attacker = { ip = "10.20.1.7", subnet = "range", public = false } # agent's tool host, no egress
    ctrl     = { ip = "10.20.2.4", subnet = "ctrl", public = true }   # harness, only public host
  }
}
