#!/bin/bash
# r-09g-autosave-long.sh — single-shot autosave verification with long wait
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p6/gui5.results
: > $LOG
printf 'AutoSaveInterval=1\n' > /root/.config/kritarc
rm -f /root/.local/share/krita.log
cp /root/p6/rt.kra /root/auto-test.kra
EX=/tmp/squashfs-root
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
timeout 900 $EX/AppRun --nosplash /root/auto-test.kra > /root/p6/auto2.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 1
done
sleep 8
xdotool windowfocus $WID; sleep 1
xdotool key --clearmodifiers b; sleep 2
xdotool mousemove 150 150; xdotool mousedown 1
for i in $(seq 1 20); do xdotool mousemove_relative 12 8; sleep 0.04; done
xdotool mouseup 1
echo "[$(date +%H:%M:%S)] stroke done; waiting 320s" >> $LOG
sleep 320
echo "[$(date +%H:%M:%S)] wait over" >> $LOG
find /root -maxdepth 2 -name "*autosave*" 2>/dev/null > /tmp/as5.txt
echo "AUTOSAVE_FILES: $(tr '\n' ' ' < /tmp/as5.txt)" >> $LOG
grep -iE "autosav" /root/.local/share/krita.log 2>/dev/null | head -4 >> $LOG
kill $KPID 2>/dev/null; kill $XPID 2>/dev/null
echo "GUI5_DONE" >> $LOG
cat $LOG
