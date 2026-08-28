#!/usr/bin/env bash
# Step 0: resource group, VNet, subnets, NSGs. Edit the config block for your sub.
set -euo pipefail
RG=ns-adlite; LOC=westus3            # NOTE: sponsorship subs are blocked from v5 VM families; westus3 has v6/v7
MYIP=$(curl -4 -s ifconfig.me)
az group create -n $RG -l $LOC -o none
az network vnet create -g $RG -n ns-vnet --address-prefixes 10.20.0.0/16 \
  --subnet-name range --subnet-prefixes 10.20.1.0/24 -o none
az network vnet subnet create -g $RG --vnet-name ns-vnet -n ctrl --address-prefixes 10.20.2.0/24 -o none
az network nsg create -g $RG -n nsg-range -o none
az network nsg create -g $RG -n nsg-ctrl -o none
az network nsg rule create -g $RG --nsg-name nsg-ctrl -n allow-ssh-me --priority 100 \
  --access Allow --direction Inbound --protocol Tcp --destination-port-ranges 22 \
  --source-address-prefixes "$MYIP/32" -o none
az network nsg rule create -g $RG --nsg-name nsg-range -n allow-vnet-in --priority 100 \
  --access Allow --direction Inbound --protocol '*' --source-address-prefixes VirtualNetwork \
  --destination-port-ranges '*' -o none
echo "network ready (egress-deny added later by 50_lock_egress.sh)"
