#!/bin/bash
echo "--- resolv inside ---"
cat /etc/resolv.conf
echo "--- curl http ---"
curl -sI --max-time 15 http://archive.ubuntu.com/ubuntu/ 2>&1 | head -3
echo "CURL_EXIT=$?"
echo "--- getent hosts ---"
getent hosts archive.ubuntu.com 2>&1 | head -2
echo "GETENT_EXIT=$?"
echo "--- direct connect test via python ---"
timeout 15 python3 -c "import socket; s=socket.create_connection(('archive.ubuntu.com',80),timeout=10); print('TCP_OK')" 2>&1
echo "--- apt get check ---"
apt-get check 2>&1 | head -3
ls /var/lib/apt/lists/ 2>/dev/null | head -5
