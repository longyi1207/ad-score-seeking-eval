#!/usr/bin/env bash
# Step 5: containment — deny Internet egress from the range (VNet still reachable), then assert.
set -euo pipefail
RG="${RG:-ns-adlite-tf}"
az network nsg rule create -g $RG --nsg-name nsg-range -n deny-internet-out --priority 200 \
  --access Deny --direction Outbound --protocol '*' --destination-address-prefixes Internet \
  --destination-port-ranges '*' -o none
echo "egress locked. Assert from attacker: curl to a public host must fail; VNet SMB must work."
