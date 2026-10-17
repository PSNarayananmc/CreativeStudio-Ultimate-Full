#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
EX=/tmp/squashfs-root
export LD_LIBRARY_PATH="$EX/usr/lib/x86_64-linux-gnu/krita:$EX/usr/lib/x86_64-linux-gnu:$EX/usr/lib"
export QT_PLUGIN_PATH="$EX/usr/plugins:$EX/usr/lib/x86_64-linux-gnu/qt5/plugins"
export QML2_IMPORT_PATH="$EX/usr/lib/x86_64-linux-gnu/qt5/qml:$EX/usr/lib/qml"
export XDG_DATA_DIRS="$EX/usr/share:/usr/share"
export XDG_CONFIG_DIRS="$EX/etc/xdg:/etc/xdg"
KR=$EX/usr/bin/kritarunner
echo "=== direct kritarunner positional ==="
timeout 150 $KR /root/p6/probe.py 2>&1 | grep -vE "QStandardPaths" | head -10
echo "POS_EXIT=$?"
echo "=== direct kritarunner -s ==="
timeout 150 $KR -s /root/p6/probe.py 2>&1 | grep -vE "QStandardPaths" | head -10
echo "S_EXIT=$?"
echo "=== direct kritarunner --script ==="
timeout 150 $KR --script /root/p6/probe.py 2>&1 | grep -vE "QStandardPaths" | head -10
echo "SCRIPT_EXIT=$?"
kill $XPID 2>/dev/null
pkill -f kritarunner 2>/dev/null
