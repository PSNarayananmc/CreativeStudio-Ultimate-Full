#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-bisect.log
: > $LOG
AI=/out/optimized.AppImage
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/squashfs-root
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
echo "EXTRACT_EXIT=$?" >> $LOG
EX=/tmp/squashfs-root
sleep 8
echo "=== P1: isolate-form ==="
timeout 120 $EX/AppRun --version 2>&1 | tail -1
echo "P1_EXIT=$?" >> $LOG
echo "=== P2: r12-form ==="
timeout 240 $EX/AppRun --version > /root/p7-version.txt 2>&1
echo "P2_EXIT=$?" >> $LOG
echo "=== P3: repeat ==="
timeout 240 $EX/AppRun --version > /root/p7-version.txt 2>&1
echo "P3_EXIT=$?" >> $LOG
kill $XPID 2>/dev/null
cat $LOG
