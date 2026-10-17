#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/gui-driver.log
: > $LOG
step() { echo "[$(date +%s)] $1" >> $LOG; }

python3 /root/make-test-input.py >> $LOG 2>&1
ls -la /root/test-input.png >> $LOG

Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
step "launching krita with test-input.png"
/krita-stage/bin/krita --nosplash /root/test-input.png > /root/gui-out.log 2>&1 &
KPID=$!

WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
step "WID=$WID"
[ -z "$WID" ] && { step "FAIL: no window"; kill $KPID $XPID; exit 1; }

sleep 5
xdotool windowfocus $WID 2>/dev/null
sleep 1
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/ev-01-open.png')" 2>/dev/null
step "open screenshot taken"

# SAVE AS: Ctrl+Shift+S
xdotool key --clearmodifiers ctrl+shift+s
sleep 4
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/ev-02-saveas-dialog.png')" 2>/dev/null
step "save dialog screenshot"
xdotool type --delay 40 "/root/gui-saved.kra"
sleep 1
xdotool key --clearmodifiers Return
sleep 12
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/ev-03-after-save.png')" 2>/dev/null
ls -la /root/gui-saved.kra >> $LOG 2>&1
step "save attempted"

# EXPORT: Ctrl+Shift+E
xdotool key --clearmodifiers ctrl+shift+e
sleep 4
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/ev-04-export-dialog.png')" 2>/dev/null
step "export dialog screenshot"
xdotool type --delay 40 "/root/gui-exported.png"
sleep 1
xdotool key --clearmodifiers Return
sleep 8
# possible merge/confirm dialog
xdotool key --clearmodifiers Return
sleep 8
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/ev-05-after-export.png')" 2>/dev/null
ls -la /root/gui-exported.png >> $LOG 2>&1
step "export attempted"

# REOPEN saved KRA via Open dialog
xdotool key --clearmodifiers ctrl+o
sleep 4
xdotool type --delay 40 "/root/gui-saved.kra"
sleep 1
xdotool key --clearmodifiers Return
sleep 15
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/ev-06-reopened.png')" 2>/dev/null
step "reopen attempted"

# quit
xdotool key --clearmodifiers ctrl+q
sleep 5
kill $KPID $XPID 2>/dev/null
step "driver done"
echo "=== DRIVER LOG ==="
cat $LOG
