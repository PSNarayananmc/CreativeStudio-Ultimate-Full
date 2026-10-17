#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
rm -f /root/gui-exported.png
timeout 150 /krita-stage/bin/krita /root/gui-saved.kra --export-filename /root/gui-exported.png > /root/cli2.log 2>&1
echo "EXIT=$?"
ls -la /root/gui-exported.png 2>/dev/null || echo "NO PNG"
file /root/gui-exported.png 2>/dev/null
kill $XPID 2>/dev/null
