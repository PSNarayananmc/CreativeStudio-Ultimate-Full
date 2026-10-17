#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/ws-driver4.log
: > $LOG
step() { echo "[$(date +%s)] $1" >> $LOG; }
shot() { python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('$1')" 2>/dev/null; }

Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
/krita-stage/bin/krita --nosplash > /root/gui-ws4.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
sleep 4
step "WID=$WID"

# create doc first (workspace with canvas context)
xdotool windowfocus $WID 2>/dev/null; sleep 1
xdotool key --clearmodifiers ctrl+n; sleep 2
xdotool key --clearmodifiers Return; sleep 6
step "doc created"

# open Window menu via keyboard (proven), then click Workspace item
xdotool windowfocus $WID 2>/dev/null; sleep 1
xdotool key --clearmodifiers alt+w; sleep 2
shot /root/ws4-01-windowmenu.png
step "window menu"
xdotool mousemove 687 215; xdotool click 1; sleep 1.5
shot /root/ws4-02-submenu.png
step "workspace submenu"
kill $KPID $XPID 2>/dev/null
step "done"
cat $LOG
