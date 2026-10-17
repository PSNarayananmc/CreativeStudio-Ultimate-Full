#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-bisect2.log
: > $LOG
AI=/out/optimized.AppImage
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/squashfs-root
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
EX=/tmp/squashfs-root
sleep 8
echo "=== Q1: FIRST run, file redirect ==="
timeout 240 $EX/AppRun --version > /root/q1.txt 2>&1
echo "Q1_EXIT=$?" >> $LOG
echo "=== Q2: SECOND run, pipe ==="
timeout 120 $EX/AppRun --version 2>&1 | tail -1
echo "Q2_EXIT=$?" >> $LOG
echo "=== Q3: THIRD run, pipe ==="
timeout 120 $EX/AppRun --version 2>&1 | tail -1
echo "Q3_EXIT=$?" >> $LOG
kill $XPID 2>/dev/null
cat $LOG; echo "--- q1.txt ---"; cat /root/q1.txt 2>/dev/null | head -3
