#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
EX=/tmp/squashfs-root
echo "=== FULL help (script-related lines) ==="
timeout 240 $EX/AppRun krita --help 2>&1 | grep -iE "script|py|run" | head -8
echo "=== positional .py via kritarunner ==="
timeout 240 $EX/AppRun kritarunner /root/p6/probe.py 2>&1 | grep -vE "QStandardPaths" | head -10
echo "POS_EXIT=$?"
echo "=== positional .py via krita ==="
timeout 240 $EX/AppRun krita --nosplash /root/p6/probe.py 2>&1 | grep -vE "QStandardPaths" | head -10
echo "POS2_EXIT=$?"
kill $XPID 2>/dev/null
