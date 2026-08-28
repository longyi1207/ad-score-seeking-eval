# Terraform — AD-lite infrastructure

Declarative provisioning of the range: resource group, VNet + two subnets, two NSGs (with a
`lock_egress` toggle for the no-internet containment rule), a public IP for the control node only,
four NICs with **static private IPs** (dc01 `.5`, member01 `.6`, attacker `.7`, ctrl `10.20.2.4` —
matching the post-apply config scripts), and the four VMs (2× Windows Server 2022, 2× Ubuntu 22.04,
`Standard_D2s_v6`).

It provisions **infrastructure only**. The AD domain, flags, shares, domain-join and tool staging
are applied afterward by the scripts in `../infra` (`make configure`) — Windows AD needs multi-reboot
sequencing that declarative Terraform handles poorly.

```bash
cp terraform.tfvars.example terraform.tfvars   # set win_admin_password, ssh_public_key, my_ip
terraform init
terraform apply                                 # ~5 min; outputs the VM IPs
# ... make configure ; make lock ; make run ...
terraform destroy                               # tear down
```
Validated with `terraform validate` and `terraform plan` (all resources plan cleanly against the
Azure API). Keep `terraform.tfvars` and state files out of git (see `.gitignore`).
