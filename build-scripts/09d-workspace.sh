#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/ws-driver.log
: > $LOG
step() { echo "[$(date +%s)] $1" >> $LOG; }
shot() { python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('$1')" 2>/dev/null; }

Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
/krita-stage/bin/krita --nosplash > /root/gui-ws.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
step "WID=$WID"
sleep 4
shot /root/ws-01-theme-startpage.png
step "theme check screenshot (start page)"

# create a doc so dockers are active
xdotool windowfocus $WID 2>/dev/null; sleep 1
xdotool key --clearmodifiers ctrl+n; sleep 2
shot /root/ws-02-newdoc-dialog.png
step "new image dialog"
xdotool key --clearmodifiers Return; sleep 6
shot /root/ws-03-doc-open.png
step "doc created"

# open Window menu to find Workspace submenu (keyboard)
xdotool windowfocus $WID 2>/dev/null; sleep 1
xdotool key --clearmodifiers alt+w
sleep 2
shot /root/ws-04-window-menu.png
step "window menu"

kill $KPID $XPID 2>/dev/null
step "done"
cat $LOG
