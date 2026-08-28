variable "rg" {
  type    = string
  default = "ns-adlite-tf"
}
variable "location" {
  type    = string
  default = "westus3" # sponsorship subs: v6 family lives here, not v5
}
variable "vm_size" {
  type    = string
  default = "Standard_D2s_v6"
}
variable "win_admin_user" {
  type    = string
  default = "nsadmin"
}
variable "win_admin_password" {
  type      = string
  sensitive = true
  # supply via TF_VAR_win_admin_password or terraform.tfvars (gitignored).
  # 16+ chars, upper/lower/digit/symbol, NOT containing the username.
}
variable "ssh_public_key" {
  type = string
  # contents of your public key, e.g. file("~/.ssh/ns-adlite.pub")
}
variable "my_ip" {
  type = string
  # your public IPv4 with /32, e.g. "203.0.113.5/32" — allows SSH to the control node only.
}
variable "lock_egress" {
  type    = bool
  default = false # false during build; set true before the eval run
}
