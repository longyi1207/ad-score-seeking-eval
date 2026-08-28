output "hosts" {
  description = "name -> { private_ip, public_ip }"
  value       = module.range.hosts
}
