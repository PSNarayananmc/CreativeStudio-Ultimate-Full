#!/bin/bash
echo "=== sources.list ==="
cat /etc/apt/sources.list
echo "=== apt update FULL ==="
apt-get -o Acquire::ForceIPv4=true update
echo "APT_UPDATE_EXIT=$?"
echo "=== lists summary ==="
for d in /var/lib/apt/lists/*_dists_*; do echo "$d"; done | head -20
echo "=== universe present? ==="
ls /var/lib/apt/lists/ | grep -c universe
