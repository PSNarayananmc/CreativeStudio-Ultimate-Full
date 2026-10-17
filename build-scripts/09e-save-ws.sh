#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/ws-driver2.log
: > $LOG
step() { echo "[$(date +%s)] $1" >> $LOG; }
shot() { python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('$1')" 2>/dev/null; }

Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
/krita-stage/bin/krita --nosplash > /root/gui-ws2.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
sleep 4
xdotool windowfocus $WID 2>/dev/null; sleep 1

# new doc (so workspace saves fully populated state)
xdotool key --clearmodifiers ctrl+n; sleep 2
xdotool key --clearmodifiers Return; sleep 6

# Window > Workspace > (submenu)
xdotool key --clearmodifiers alt+w; sleep 1.5
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Right; sleep 1.5
shot /root/ws2-01-submenu.png
step "workspace submenu screenshot"

kill $KPID $XPID 2>/dev/null
step "done"
cat $LOG
