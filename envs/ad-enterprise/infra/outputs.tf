output "hosts" {
  description = "name -> { private_ip, public_ip }"
  value       = module.range.hosts
}

output "rg" {
  value = module.range.rg
}
