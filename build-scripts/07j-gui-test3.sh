#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/gui-driver3.log
: > $LOG
step() { echo "[$(date +%s)] $1" >> $LOG; }
shot() { python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('$1')" 2>/dev/null; }

rm -f /root/gui-saved.kra /root/gui-exported.png /root/reopened.kra
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
/krita-stage/bin/krita --nosplash /root/test-input.png > /root/gui-out3.log 2>&1 &
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

# 1. paint a stroke (edit evidence)
xdotool key --clearmodifiers b
sleep 2
xdotool mousemove 700 350
xdotool mousedown 1
for i in $(seq 1 35); do xdotool mousemove_relative 9 6; sleep 0.04; done
xdotool mouseup 1
sleep 2
shot /root/ev3-01-strokes.png
step "strokes painted"

# 2. SAVE AS via ctrl+shift+s
xdotool key --clearmodifiers ctrl+shift+s
sleep 4
xdotool type --delay 35 "/root/gui-saved.kra"
sleep 1
xdotool key --clearmodifiers Return
sleep 12
ls -la /root/gui-saved.kra >> $LOG 2>&1
step "save-as done"
shot /root/ev3-02-after-save.png

# 3. EXPORT via File menu click
xdotool key --clearmodifiers alt+f
sleep 2
xdotool mousemove 308 322
xdotool click 1
sleep 5
shot /root/ev3-03-export-dialog.png
xdotool type --delay 35 "/root/gui-exported.png"
sleep 1
xdotool key --clearmodifiers Return
sleep 8
xdotool key --clearmodifiers Return
sleep 8
ls -la /root/gui-exported.png >> $LOG 2>&1
step "export attempted"
shot /root/ev3-04-after-export.png

# 4. REOPEN the saved KRA (discards current doc => discard dialog may appear)
xdotool key --clearmodifiers ctrl+o
sleep 4
shot /root/ev3-05-open-dialog.png
xdotool type --delay 35 "/root/gui-saved.kra"
sleep 1
xdotool key --clearmodifiers Return
sleep 4
# discard changes prompt for the modified test-input doc?
shot /root/ev3-06-discard-prompt.png
xdotool mousemove 764 570
xdotool click 1
sleep 10
shot /root/ev3-07-reopened.png
step "reopen attempted"

# 5. QUIT
xdotool key --clearmodifiers ctrl+q
sleep 4
shot /root/ev3-08-quit.png
xdotool mousemove 764 570
xdotool click 1
sleep 3
kill $KPID $XPID 2>/dev/null
step "done"
cat $LOG
