#!/usr/bin/env bash
# stage attacker tools via the control node (over the private VNet). env-agnostic.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
KEY="${SSH_KEY:-$HERE/ssh_key}"
CTRL="${CTRL_IP:-$(terraform -chdir="$HERE/infra" output -json hosts 2>/dev/null | python3 -c "import sys,json;print(json.load(sys.stdin)['ctrl']['public_ip'])")}"
ATT="${ATTACKER_IP:-10.20.1.7}"
cat > /tmp/_stage.sh <<'SH'
set -uo pipefail; ATT="$1"; export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -q >/dev/null 2>&1; rm -rf /tmp/pkgs; mkdir -p /tmp/pkgs
sudo apt-get install --download-only -y nmap smbclient ldap-utils krb5-user dnsutils netcat-openbsd python3-pip >/dev/null 2>&1
sudo cp /var/cache/apt/archives/*.deb /tmp/pkgs/ 2>/dev/null; sudo chown "$(whoami)" /tmp/pkgs/*.deb 2>/dev/null || true
python3 -m pip download -q -d /tmp/pkgs impacket 2>&1 | tail -1 || true
ssh -o StrictHostKeyChecking=no azureuser@$ATT 'rm -rf /tmp/pkgs && mkdir -p /tmp/pkgs'
scp -o StrictHostKeyChecking=no -q /tmp/pkgs/* azureuser@$ATT:/tmp/pkgs/
ssh -o StrictHostKeyChecking=no azureuser@$ATT 'echo krb5-config krb5-config/default_realm string ENTERPRISE.NORTHSTAR.LAB | sudo debconf-set-selections; sudo DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/pkgs/*.deb >/tmp/dpkg.log 2>&1; sudo pip3 install --no-index --find-links /tmp/pkgs impacket >/tmp/pip.log 2>&1; for t in nmap smbclient ldapsearch; do command -v $t >/dev/null && echo "$t ok"; done'
SH
scp -i "$KEY" -o StrictHostKeyChecking=no -q /tmp/_stage.sh "azureuser@$CTRL:~/_stage.sh"
ssh -i "$KEY" -o StrictHostKeyChecking=no "azureuser@$CTRL" "bash ~/_stage.sh $ATT"
