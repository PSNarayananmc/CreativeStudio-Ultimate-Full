#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/gui-driver2.log
: > $LOG
step() { echo "[$(date +%s)] $1" >> $LOG; }
shot() { python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('$1')" 2>/dev/null; }

Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
/krita-stage/bin/krita --nosplash /root/test-input.png > /root/gui-out2.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
step "WID=$WID"
sleep 5
xdotool windowfocus $WID 2>/dev/null
sleep 1

# select freehand brush tool (B)
xdotool key --clearmodifiers b
sleep 2
# set a small brush size via bracket keys a few times
for i in 1 2 3; do xdotool key --clearmodifiers bracketright; sleep 0.3; done
step "brush tool selected, painting strokes"
# paint strokes: red (FG) — set FG color to red via key? default is fine; paint arcs
xdotool mousemove 700 350
xdotool mousedown 1
for i in $(seq 1 40); do
  xdotool mousemove_relative 8 6
  sleep 0.05
done
xdotool mouseup 1
sleep 1
xdotool mousemove 640 560
xdotool mousedown 1
for i in $(seq 1 30); do
  xdotool mousemove_relative 10 -7
  sleep 0.05
done
xdotool mouseup 1
sleep 3
shot /root/ev2-01-strokes.png
step "strokes painted"

# open File menu
xdotool key --clearmodifiers alt+f
sleep 2
shot /root/ev2-02-filemenu.png
step "file menu open"

kill $KPID $XPID 2>/dev/null
step "done"
cat $LOG
