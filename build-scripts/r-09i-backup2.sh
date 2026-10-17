#!/bin/bash
# r-09h-backup-test.sh — verify backup-on-save (.kra~) works
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p6/gui6.results
: > $LOG
printf 'AutoSaveInterval=1\nbackupFile=true\n' > /root/.config/kritarc
cp /root/p6/rt.kra /root/bk-test.kra
rm -f /root/bk-test.kra~
EX=/tmp/squashfs-root
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
timeout 600 $EX/AppRun --nosplash /root/bk-test.kra > /root/p6/bk.log 2>&1 &
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
xdotool mouseup 1; sleep 3
echo "[$(date +%H:%M:%S)] stroke done; ctrl+s" >> $LOG
xdotool key --clearmodifiers ctrl+s; sleep 15
ls -la /root/bk-test.kra /root/bk-test.kra~ >> $LOG 2>&1
BK=$(ls /root/bk-test.kra~ 2>/dev/null)
echo "RESULT: backup_file_on_save = $(if [ -n "$BK" ]; then echo PASS; else echo FAIL; fi) file=$BK" >> $LOG
# autosave last-chance check (timer may have started post-save)
sleep 30
find /root -maxdepth 2 -name "*autosave*" >> /tmp/as6.txt 2>/dev/null
echo "RESULT: autosave_files_now = $(tr '\n' ' ' < /tmp/as6.txt)" >> $LOG
kill $KPID 2>/dev/null; kill $XPID 2>/dev/null
echo "GUI6_DONE" >> $LOG
cat $LOG
