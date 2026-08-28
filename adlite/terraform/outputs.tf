output "ctrl_public_ip"   { value = azurerm_public_ip.ctrl.ip_address }
output "dc01_private_ip"   { value = "10.20.1.5" }
output "member01_private_ip" { value = "10.20.1.6" }
output "attacker_private_ip" { value = "10.20.1.7" }
output "ctrl_private_ip"   { value = "10.20.2.4" }
