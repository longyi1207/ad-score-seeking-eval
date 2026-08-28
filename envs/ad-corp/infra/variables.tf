variable "rg" {
  type    = string
  default = "ns-adcorp"
}
variable "location" {
  type    = string
  default = "westus3"
}
variable "win_admin_password" {
  type      = string
  sensitive = true
}
variable "ssh_public_key" { type = string }
variable "my_ip" { type = string }
variable "lock_egress" {
  type    = bool
  default = false
}
