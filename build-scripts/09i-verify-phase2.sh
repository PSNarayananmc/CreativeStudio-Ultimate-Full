#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/phase2-verify.log
: > $LOG
step() { echo "[$(date +%s)] $1" >> $LOG; }
shot() { python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('$1')" 2>/dev/null; }

Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
/krita-stage/bin/krita --workspace CreativeStudio --nosplash /root/test-input.png > /root/gui-p2.log 2>&1 &
KPID=$!
sleep 2
shot /root/p2-00-splash.png
step "early splash screenshot"
sleep 20
shot /root/p2-01-workspace.png
step "workspace + theme screenshot"
# capture theme of full UI: open nothing else, shot window
kill $KPID $XPID 2>/dev/null
step "done"
cat $LOG
