#!/bin/bash
export HOME=/root
export DISPLAY=:77
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
rm -f /root/cli-test.png
timeout 180 /krita-stage/bin/krita --nosplash --new-image RGBA,U8,64,64 --export-filename /root/cli-test.png > /root/cli-out.log 2>&1
echo "KRITA_EXIT=$?"
ls -la /root/cli-test.png 2>/dev/null || echo "NO PNG"
file /root/cli-test.png 2>/dev/null
kill $XPID 2>/dev/null
tail -5 /root/cli-out.log
