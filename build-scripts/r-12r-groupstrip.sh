#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-group.log
: > $LOG
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 5
EX=/tmp/squashfs-root
sstrip() { find "$1" -maxdepth 1 -name "$2" -type f | while read f; do strip --strip-unneeded "$f" 2>/dev/null; done; }
cnt() { find "$1" -maxdepth 1 -name "$2" -type f | wc -l; }
probe() { timeout 240 $EX/AppRun --version > /root/probe.txt 2>&1; echo "PROBE_$1=$?"; }
probe D0 >> $LOG
echo "kf5_count=$(cnt $EX/usr/lib 'libKF5*.so*')" >> $LOG
sstrip $EX/usr/lib 'libKF5*.so*'
probe D1_kf5 >> $LOG
sstrip $EX/usr/lib 'libkrita*.so*'
probe D2_krita >> $LOG
sstrip $EX/usr/lib 'libQt5*.so*'
probe D3_qt >> $LOG
sstrip $EX/usr/lib 'lib**.so*'
probe D4_rest_toplevel >> $LOG
sstrip $EX/usr/lib/x86_64-linux-gnu '*.so*'
probe D5_x8664 >> $LOG
kill $XPID 2>/dev/null
cat $LOG
