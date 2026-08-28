output "hosts" {
  description = "map: name -> { private_ip, public_ip }"
  value = merge(
    { for k, v in var.windows_hosts : k => {
      private_ip = v.ip
      public_ip  = null
    } },
    { for k, v in var.linux_hosts : k => {
      private_ip = v.ip
      public_ip  = v.public ? azurerm_public_ip.host[k].ip_address : null
    } },
  )
}

output "rg" {
  value = azurerm_resource_group.rg.name
}
