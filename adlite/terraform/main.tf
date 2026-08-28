# AD-lite range — infrastructure as code.
# Provisions the 4-VM range (2 Windows + 2 Linux) with the SAME static private IPs the
# post-apply config scripts expect (dc01 .5, member01 .6, attacker .7, ctrl .2.4), so
# `make configure` runs unchanged after `terraform apply`.
#
# Provisions infrastructure only; the AD domain / flags / shares / tool install are applied
# post-apply by the scripts in ../infra (Windows AD needs multi-reboot sequencing that is
# poorly suited to declarative Terraform). See ../../Makefile.

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

resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.location
}

# ---------- network ----------
resource "azurerm_virtual_network" "vnet" {
  name                = "ns-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.20.0.0/16"]
}
resource "azurerm_subnet" "range" {
  name                 = "range"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.1.0/24"]
}
resource "azurerm_subnet" "ctrl" {
  name                 = "ctrl"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.2.0/24"]
}

# ---------- NSGs ----------
resource "azurerm_network_security_group" "range" {
  name                = "nsg-range"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  security_rule {
    name                       = "allow-vnet-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Containment: deny all outbound to the internet (VNet traffic still allowed by the
  # default AllowVnetOutBound rule). Toggle with var.lock_egress — off during build
  # (the attacker needs its tools staged), on before the eval run.
  dynamic "security_rule" {
    for_each = var.lock_egress ? [1] : []
    content {
      name                       = "deny-internet-out"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  }
}
resource "azurerm_network_security_group" "ctrl" {
  name                = "nsg-ctrl"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  security_rule {
    name                       = "allow-ssh-me"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "range" {
  subnet_id                 = azurerm_subnet.range.id
  network_security_group_id = azurerm_network_security_group.range.id
}
resource "azurerm_subnet_network_security_group_association" "ctrl" {
  subnet_id                 = azurerm_subnet.ctrl.id
  network_security_group_id = azurerm_network_security_group.ctrl.id
}

# ---------- public IP for the control node only ----------
resource "azurerm_public_ip" "ctrl" {
  name                = "ctrl-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ---------- NICs (static IPs matching the config scripts) ----------
locals {
  range_hosts = {
    dc01     = "10.20.1.5"
    member01 = "10.20.1.6"
    attacker = "10.20.1.7"
  }
}
resource "azurerm_network_interface" "range" {
  for_each            = local.range_hosts
  name                = "${each.key}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = azurerm_subnet.range.id
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value
    # no public IP: range hosts are never internet-reachable
  }
}
resource "azurerm_network_interface" "ctrl" {
  name                = "ctrl-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = azurerm_subnet.ctrl.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.20.2.4"
    public_ip_address_id          = azurerm_public_ip.ctrl.id
  }
}

# ---------- Windows VMs: dc01, member01 ----------
resource "azurerm_windows_virtual_machine" "win" {
  for_each              = { dc01 = "dc01", member01 = "member01" }
  name                  = each.key
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = var.win_admin_user
  admin_password        = var.win_admin_password
  network_interface_ids = [azurerm_network_interface.range[each.key].id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
}

# ---------- Linux VMs: attacker (no public IP), ctrl (public) ----------
resource "azurerm_linux_virtual_machine" "attacker" {
  name                  = "attacker"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.range["attacker"].id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
resource "azurerm_linux_virtual_machine" "ctrl" {
  name                  = "ctrl"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.ctrl.id]
  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
