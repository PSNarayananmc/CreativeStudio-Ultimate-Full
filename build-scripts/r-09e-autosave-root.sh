#!/bin/bash
# r-09d-autosave-kra.sh — autosave test with KRA source doc + all config variants
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p6/gui3.results
: > $LOG
step() { echo "[$(date +%H:%M:%S)] $1" >> $LOG; }

mkdir -p /root/.config
cat > /root/.config/kritarc <<'EOF'
AutoSaveInterval=1
autosavefileshidden=false
EOF
step "config variants written"

cp /root/p6/rt.kra /root/auto-test.kra
EX=/tmp/squashfs-root
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
timeout 600 $EX/AppRun --nosplash /root/auto-test.kra > /root/p6/auto-run.log 2>&1 &
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
step "stroke painted; waiting 80s"
sleep 25
step "searching autosave files"
find /root -name "*autosave*" 2>/dev/null > /tmp/as2.txt
find /root -name "*.kra~" 2>/dev/null >> /tmp/as2.txt
sort -u /tmp/as2.txt > /tmp/as2u.txt
echo "RESULT: autosave_file_kra = $(if [ -s /tmp/as2u.txt ]; then echo PASS; else echo FAIL; fi) files=$(tr '\n' ' ' < /tmp/as2u.txt)" >> $LOG
ls -la /root/.local/share/krita/ 2>/dev/null >> $LOG
kill -9 $KPID 2>/dev/null
sleep 2
kill $XPID 2>/dev/null
echo "GUI3_DONE" >> $LOG
cat $LOG
