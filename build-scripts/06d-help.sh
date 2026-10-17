#!/bin/bash
export HOME=/root
export DISPLAY=:77
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
/krita-stage/bin/krita --version 2>&1 | tail -2
echo "---KRITARUNNER---"
/krita-stage/bin/kritarunner --help 2>&1 | head -12
kill $XPID 2>/dev/null
