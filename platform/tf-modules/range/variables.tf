variable "rg" {
  type        = string
  description = "resource group name (isolated per env)"
}
variable "location" {
  type    = string
  default = "westus3" # sponsorship subs: v6 VM family lives here, not v5
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
}
variable "ssh_public_key" {
  type = string
}
variable "my_ip" {
  type        = string
  description = "your public IPv4 with /32; allows SSH to public (control) hosts only"
}
variable "lock_egress" {
  type        = bool
  default     = false
  description = "true = deny all internet egress from the range subnet (containment)"
}

# Topology as data. Each env supplies its host lists; the module builds the rest.
variable "windows_hosts" {
  description = "map: name -> { ip, subnet=range, size }"
  type = map(object({
    ip     = string
    subnet = optional(string, "range")
    size   = optional(string)
  }))
  default = {}
}
variable "linux_hosts" {
  description = "map: name -> { ip, subnet, public, size }"
  type = map(object({
    ip     = string
    subnet = optional(string, "range")
    public = optional(bool, false)
    size   = optional(string)
  }))
  default = {}
}
variable "vnet_cidr" {
  type    = string
  default = "10.20.0.0/16"
}
variable "range_cidr" {
  type    = string
  default = "10.20.1.0/24"
}
variable "ctrl_cidr" {
  type    = string
  default = "10.20.2.0/24"
}
