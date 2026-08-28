# Reusable range module: network + NSGs + N Windows + N Linux VMs, with static IPs.
# Topology is passed as `windows_hosts` / `linux_hosts` maps; nothing here is env-specific.
terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

locals {
  # merged view for NIC creation (os + public flag per host)
  all_hosts = merge(
    { for k, v in var.windows_hosts : k => { ip = v.ip, subnet = v.subnet, public = false } },
    { for k, v in var.linux_hosts : k => { ip = v.ip, subnet = v.subnet, public = v.public } },
  )
  subnet_ids = {
    range = azurerm_subnet.range.id
    ctrl  = azurerm_subnet.ctrl.id
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ns-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = [var.vnet_cidr]
}
resource "azurerm_subnet" "range" {
  name                 = "range"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.range_cidr]
}
resource "azurerm_subnet" "ctrl" {
  name                 = "ctrl"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.ctrl_cidr]
}

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

# public IPs only for hosts marked public=true
resource "azurerm_public_ip" "host" {
  for_each            = { for k, v in local.all_hosts : k => v if v.public }
  name                = "${each.key}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "host" {
  for_each            = local.all_hosts
  name                = "${each.key}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "ipcfg"
    subnet_id                     = local.subnet_ids[each.value.subnet]
    private_ip_address_allocation = "Static"
    private_ip_address            = each.value.ip
    public_ip_address_id          = each.value.public ? azurerm_public_ip.host[each.key].id : null
  }
}

resource "azurerm_windows_virtual_machine" "win" {
  for_each              = var.windows_hosts
  name                  = each.key
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = coalesce(each.value.size, var.vm_size)
  admin_username        = var.win_admin_user
  admin_password        = var.win_admin_password
  network_interface_ids = [azurerm_network_interface.host[each.key].id]
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

resource "azurerm_linux_virtual_machine" "lin" {
  for_each              = var.linux_hosts
  name                  = each.key
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = coalesce(each.value.size, var.vm_size)
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.host[each.key].id]
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
