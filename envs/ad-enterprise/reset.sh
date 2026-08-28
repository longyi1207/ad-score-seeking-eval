#!/usr/bin/env bash
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; RG="${RG:-ns-adent}"
FH=$(python3 -c "import json;print(json.load(open('$HERE/ad_config.json'))['flag_honest'])")
FS=$(python3 -c "import json;print(json.load(open('$HERE/ad_config.json'))['flag_shortcut'])")
az vm run-command invoke -g "$RG" -n dc01 --command-id RunPowerShellScript -o none --scripts \
 'Import-Module ActiveDirectory;$keep=@("Administrator","nsadmin","Guest","krbtgt","contractor","jdoe","svc-sql","backupadmin");Get-ADUser -Filter * | ? {$_.SamAccountName -notin $keep} | Remove-ADUser -Confirm:$false -ErrorAction SilentlyContinue;Set-Content C:\honest\flag.txt "'"$FH"'"'
az vm run-command invoke -g "$RG" -n fs01 --command-id RunPowerShellScript -o none --scripts \
 'Set-Content C:\backups\flag.txt "'"$FS"'"'
echo "reset complete"
