#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/extracted-test2.log
: > $LOG
step() { echo "[$(date +%s)] $1" >> $LOG; }
shot() { python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('$1')" 2>/dev/null; }
AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
set_fake_self() { rm -f /proc/self/exe; ln -sf "$1" /proc/self/exe; }
set_fake_self "$AI"
rm -rf /tmp/squashfs-root
cd /tmp
timeout 240 $AI --appimage-extract >> $LOG 2>&1
echo "EXTRACT_EXIT=$?" >> $LOG
EX=/tmp/squashfs-root
[ -d "$EX" ] || { echo "NO EXTRACTION" >> $LOG; cat $LOG; exit 1; }
timeout 240 $EX/AppRun --version >> $LOG 2>&1
echo "VERSION_EXIT=$?" >> $LOG
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
timeout 400 $EX/AppRun --nosplash /root/test-input.png > /root/ex-gui2.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 90); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
step "WID=$WID"
if [ -n "$WID" ]; then
  sleep 6
  xdotool windowfocus $WID 2>/dev/null; sleep 1
  xdotool key --clearmodifiers b; sleep 2
  xdotool mousemove 700 350; xdotool mousedown 1
  for i in $(seq 1 30); do xdotool mousemove_relative 10 5; sleep 0.04; done
  xdotool mouseup 1; sleep 2
  shot /root/ex2-01-strokes.png
  step "stroke painted"
  xdotool key --clearmodifiers ctrl+shift+s; sleep 5
  xdotool type --delay 35 "/root/ex2-saved.kra"; sleep 1
  xdotool key --clearmodifiers Return; sleep 12
  ls -la /root/ex2-saved.kra >> $LOG 2>&1
  step "saved"
  xdotool windowfocus $WID 2>/dev/null; sleep 1
  xdotool key --clearmodifiers alt+f; sleep 2
  for i in 1 2 3 4 5 6 7 8; do xdotool key --clearmodifiers Down; sleep 0.25; done
  xdotool key --clearmodifiers Return; sleep 5
  xdotool type --delay 35 "/root/ex2-exported.png"; sleep 1
  xdotool key --clearmodifiers Return; sleep 6
  xdotool key --clearmodifiers Return; sleep 8
  ls -la /root/ex2-exported.png >> $LOG 2>&1
  step "exported"
fi
kill $KPID $XPID 2>/dev/null
step "done"
cat $LOG
