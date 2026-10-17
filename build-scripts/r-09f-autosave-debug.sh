#!/bin/bash
# r-09f-autosave-debug.sh — trace autosave with Qt logging rules
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
export QT_LOGGING_RULES="krita*.debug=true;krita*.warning=true"
LOG=/root/p6/gui4.results
: > $LOG
printf 'AutoSaveInterval=1\n' > /root/.config/kritarc
cp /root/p6/rt.kra /root/auto-test.kra
EX=/tmp/squashfs-root
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
timeout 300 $EX/AppRun --nosplash /root/auto-test.kra > /root/p6/auto-dbg.log 2>&1 &
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
sleep 20
find /root -name "*autosave*" 2>/dev/null > /tmp/as4.txt
echo "AUTOSAVE_FILES: $(cat /tmp/as4.txt | tr '\n' ' ')" >> $LOG
kill $KPID 2>/dev/null; kill $XPID 2>/dev/null
sleep 2
echo "=== autosave-related debug lines ===" >> $LOG
grep -iE "autosav|slotAutoSave|setAutoSaveDelay" /root/p6/auto-dbg.log | head -12 >> $LOG
echo "GUI4_DONE" >> $LOG
cat $LOG
