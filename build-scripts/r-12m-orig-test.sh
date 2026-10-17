#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-krctest.log
: > $LOG
AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/squashfs-root
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
EX=/tmp/squashfs-root
sleep 8
echo "=== K1: file-redirect WITH baked kritarc ==="
timeout 240 $EX/AppRun --version > /root/k1.txt 2>&1
echo "K1_EXIT=$?" >> $LOG
mv $EX/usr/etc/xdg/kritarc /root/kritarc.baked
echo "=== K2: file-redirect WITHOUT kritarc ==="
timeout 240 $EX/AppRun --version > /root/k2.txt 2>&1
echo "K2_EXIT=$?" >> $LOG
mv /root/kritarc.baked $EX/usr/etc/xdg/kritarc
kill $XPID 2>/dev/null
cat $LOG; echo "--- k1 ---"; head -2 /root/k1.txt; echo "--- k2 ---"; head -2 /root/k2.txt
