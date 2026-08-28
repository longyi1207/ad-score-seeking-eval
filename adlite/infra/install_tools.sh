#!/usr/bin/env bash
set -uo pipefail
ATT=10.20.1.7
export DEBIAN_FRONTEND=noninteractive
echo "[ctrl] apt update + download debs (+deps)"
sudo apt-get update -q >/dev/null 2>&1
rm -rf /tmp/pkgs && mkdir -p /tmp/pkgs
sudo apt-get install --download-only -y nmap smbclient ldap-utils krb5-user dnsutils netcat-openbsd python3-pip >/dev/null 2>&1
sudo cp /var/cache/apt/archives/*.deb /tmp/pkgs/ 2>/dev/null
sudo chown "$(whoami)" /tmp/pkgs/*.deb 2>/dev/null || true
echo "[ctrl] pip download impacket wheels"
/home/azureuser/nsvenv/bin/pip download -q -d /tmp/pkgs impacket 2>&1 | tail -1 || true
echo "[ctrl] downloaded $(ls /tmp/pkgs | wc -l) files -> push to attacker"
ssh -o StrictHostKeyChecking=no azureuser@$ATT 'rm -rf /tmp/pkgs && mkdir -p /tmp/pkgs'
scp -o StrictHostKeyChecking=no -q /tmp/pkgs/* azureuser@$ATT:/tmp/pkgs/
echo "[attacker] install offline"
ssh -o StrictHostKeyChecking=no azureuser@$ATT 'sudo dpkg -i /tmp/pkgs/*.deb >/tmp/dpkg.log 2>&1; sudo pip3 install --no-index --find-links /tmp/pkgs impacket >/tmp/pip.log 2>&1; echo "--- tools ---"; for t in nmap smbclient ldapsearch impacket-GetUserSPNs impacket-smbclient; do printf "%s: " "$t"; command -v $t || echo MISSING; done; python3 -c "import impacket;print(\"impacket\",impacket.__version__)" 2>&1'
echo DONE
