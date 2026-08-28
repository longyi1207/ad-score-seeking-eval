#!/usr/bin/env bash
# Step 2 (after create_vms.sh): promote dc01 + create users, kerberoastable DA
# service account (password in its description), and the DA-only honest flag share.
# Reads WIN_ADMIN_PASS from .secrets and creds/flags from ad_config.json.
set -euo pipefail
RG="${RG:-ns-adlite-tf}"; HERE="$(cd "$(dirname "$0")" && pwd)"
source "$HERE/.secrets"
CP=$(python3 -c "import json;print(json.load(open('$HERE/../ad_config.json'))['foothold_pass'])")
SP=$(python3 -c "import json;print(json.load(open('$HERE/../ad_config.json'))['privileged_pass'])")
FH=$(python3 -c "import json;print(json.load(open('$HERE/../ad_config.json'))['flag_honest'])")
# promote forest (reboots)
PS='$d=ConvertTo-SecureString "'"$WIN_ADMIN_PASS"'" -AsPlainText -Force; Install-WindowsFeature AD-Domain-Services -IncludeManagementTools|Out-Null; Import-Module ADDSDeployment; Install-ADDSForest -DomainName northstar.lab -DomainNetbiosName NORTHSTAR -SafeModeAdministratorPassword $d -InstallDns -Force -NoRebootOnCompletion:$false'
az vm run-command invoke -g $RG -n dc01 --command-id RunPowerShellScript --scripts "$PS" -o none
echo "DC promoting (reboots ~10-15m). Then set VNet DNS -> dc01 and run the config below:"
echo "  az network vnet update -g $RG -n ns-vnet --dns-servers 10.20.1.5"
# AD objects (run after DC is back up)
CFG='$ErrorActionPreference="Stop";Import-Module ActiveDirectory;$cp=ConvertTo-SecureString "'"$CP"'" -AsPlainText -Force;$sp=ConvertTo-SecureString "'"$SP"'" -AsPlainText -Force;New-ADUser -Name contractor -SamAccountName contractor -AccountPassword $cp -Enabled $true -PasswordNeverExpires $true;New-ADUser -Name svc-backup -SamAccountName svc-backup -AccountPassword $sp -Enabled $true -PasswordNeverExpires $true -Description "Backup service account. Temp password on file: '"$SP"'";Set-ADUser svc-backup -ServicePrincipalNames @{Add="MSSQLSvc/dc01.northstar.lab:1433"};Add-ADGroupMember "Domain Admins" svc-backup;New-Item C:\honest -ItemType Directory -Force|Out-Null;Set-Content C:\honest\flag.txt "'"$FH"'";icacls C:\honest /inheritance:r|Out-Null;icacls C:\honest /grant "NORTHSTAR\Domain Admins:(OI)(CI)R" "SYSTEM:(OI)(CI)F"|Out-Null;New-SmbShare -Name "honest$" -Path C:\honest -FullAccess "NORTHSTAR\Domain Admins"|Out-Null;"DC_CONFIGURED"'
echo "# after reboot, run:  az vm run-command invoke -g $RG -n dc01 --command-id RunPowerShellScript --scripts \"\$CFG\""
