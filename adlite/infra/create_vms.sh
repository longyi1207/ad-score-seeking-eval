#!/usr/bin/env bash
# AD-lite MVP — create the 4-VM fleet. Idempotent-ish; safe to re-run.
set -uo pipefail
RG="${RG:-ns-adlite-tf}"; LOC=westus3; VNET=ns-vnet
BASE="$(cd "$(dirname "$0")" && pwd)"
source "$BASE/.secrets"           # WIN_ADMIN_USER / WIN_ADMIN_PASS (gitignored)

log(){ echo "[$(date +%H:%M:%S)] $*"; }

# attach NSGs to subnets
log "attach NSGs"
az network vnet subnet update -g $RG --vnet-name $VNET -n range --network-security-group nsg-range -o none
az network vnet subnet update -g $RG --vnet-name $VNET -n ctrl  --network-security-group nsg-ctrl  -o none

# ssh key
if [ ! -f "$BASE/ssh_adlite" ]; then
  ssh-keygen -t ed25519 -f "$BASE/ssh_adlite" -N "" -C ns-adlite >/dev/null
  log "ssh key generated"
fi
KEY="$BASE/ssh_adlite.pub"

# accept Kali marketplace terms
log "accept kali terms"
az vm image terms accept --urn decyphertek:kali:kali:latest -o none 2>/dev/null || log "kali terms (already/również)"

# control node (Ubuntu, public IP, egress ok)
log "create control (ubuntu B2s, public IP)"
az vm create -g $RG -n ctrl --image Ubuntu2204 --size Standard_D2s_v6 \
  --subnet ctrl --vnet-name $VNET --admin-username azureuser \
  --ssh-key-values "$KEY" --public-ip-sku Standard -o none && log "control OK"

# kali attacker (range subnet, NO public IP)
log "create kali (D2s_v5, no public IP)"
az vm create -g $RG -n kali --image decyphertek:kali:kali:latest --size Standard_D2s_v6 \
  --subnet range --vnet-name $VNET --admin-username azureuser \
  --ssh-key-values "$KEY" --public-ip-address "" \
  --plan-name kali --plan-product kali --plan-publisher decyphertek -o none && log "kali OK" \
  || log "kali FAILED (check plan/urn)"

# DC (Windows Server 2022, range subnet, NO public IP)
log "create DC (Win2022 D2s_v5, no public IP)"
az vm create -g $RG -n dc01 --image Win2022Datacenter --size Standard_D2s_v6 \
  --subnet range --vnet-name $VNET --admin-username "$WIN_ADMIN_USER" \
  --admin-password "$WIN_ADMIN_PASS" --public-ip-address "" -o none && log "dc01 OK"

# MEMBER (Windows Server 2022, range subnet, NO public IP)
log "create MEMBER (Win2022 D2s_v5, no public IP)"
az vm create -g $RG -n member01 --image Win2022Datacenter --size Standard_D2s_v6 \
  --subnet range --vnet-name $VNET --admin-username "$WIN_ADMIN_USER" \
  --admin-password "$WIN_ADMIN_PASS" --public-ip-address "" -o none && log "member01 OK"

log "=== done. private IPs ==="
az vm list-ip-addresses -g $RG -o json | python3 -c "
import sys,json
for v in json.load(sys.stdin):
    n=v['virtualMachine']['name']; net=v['virtualMachine']['network']
    pri=[i['privateIpAddresses'] for i in net.get('privateIpAddresses',[])] if False else net.get('privateIpAddresses')
    pub=net.get('publicIpAddresses',[])
    pubip=pub[0]['ipAddress'] if pub else '-'
    print(f'{n:10} priv={net[\"privateIpAddresses\"]} pub={pubip}')
"
