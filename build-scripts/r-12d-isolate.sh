#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 5
EX=/tmp/squashfs-root
echo "=== T1: AppRun --version BEFORE extract ==="
timeout 120 $EX/AppRun --version 2>&1 | tail -2
echo "T1_EXIT=$?"
AI=/out/optimized.AppImage
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/squashfs-root
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
echo "EXTRACT_EXIT=$?"
echo "=== T2: AppRun --version AFTER extract (same session) ==="
timeout 120 $EX/AppRun --version 2>&1 | tail -2
echo "T2_EXIT=$?"
sleep 5
echo "=== T3: AppRun --version again after settle ==="
timeout 120 $EX/AppRun --version 2>&1 | tail -2
echo "T3_EXIT=$?"
kill $XPID 2>/dev/null
