#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/gui-driver4.log
: > $LOG
step() { echo "[$(date +%s)] $1" >> $LOG; }
shot() { python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('$1')" 2>/dev/null; }
wait_dialog() { # wait for any new dialog window
  for i in $(seq 1 25); do
    sleep 1
    N=$(xdotool search --onlyvisible --name "" 2>/dev/null | grep -v "^$WID$" | wc -l)
    [ "$N" -gt 0 ] && return 0
  done
  return 1
}

rm -f /root/gui-saved.kra /root/gui-exported.png
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
/krita-stage/bin/krita --nosplash /root/test-input.png > /root/gui-out4.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
step "WID=$WID"
sleep 5

# --- EDIT: brush stroke ---
xdotool windowfocus $WID 2>/dev/null; sleep 1
xdotool key --clearmodifiers b; sleep 2
xdotool mousemove 700 350; xdotool mousedown 1
for i in $(seq 1 35); do xdotool mousemove_relative 9 6; sleep 0.04; done
xdotool mouseup 1; sleep 2
step "stroke painted"

# --- EXPORT via File menu (keyboard nav) ---
xdotool windowfocus $WID 2>/dev/null; sleep 1
xdotool key --clearmodifiers alt+f; sleep 2
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Down; sleep 0.3
xdotool key --clearmodifiers Return
if wait_dialog; then step "export dialog appeared"; else step "export dialog NOT detected"; fi
shot /root/ev4-01-export-dialog.png
xdotool type --delay 35 "/root/gui-exported.png"; sleep 1
xdotool key --clearmodifiers Return
sleep 6
xdotool key --clearmodifiers Return
sleep 8
ls -la /root/gui-exported.png >> $LOG 2>&1
step "export done"
shot /root/ev4-02-after-export.png

# --- SAVE AS KRA ---
xdotool windowfocus $WID 2>/dev/null; sleep 1
xdotool key --clearmodifiers ctrl+shift+s
if wait_dialog; then step "save dialog appeared"; fi
xdotool type --delay 35 "/root/gui-saved.kra"; sleep 1
xdotool key --clearmodifiers Return
sleep 10
ls -la /root/gui-saved.kra >> $LOG 2>&1
step "save done"

# --- REOPEN saved file ---
xdotool windowfocus $WID 2>/dev/null; sleep 1
xdotool key --clearmodifiers ctrl+o
if wait_dialog; then step "open dialog appeared"; fi
xdotool type --delay 35 "/root/gui-saved.kra"; sleep 1
xdotool key --clearmodifiers Return
sleep 6
shot /root/ev4-03-maybe-discard.png
xdotool key --clearmodifiers Tab; sleep 0.5
xdotool key --clearmodifiers Return
sleep 10
shot /root/ev4-04-reopened.png
step "reopen done"

# --- UNDO/REDO evidence: paint + undo ---
xdotool mousemove 600 300; xdotool mousedown 1
for i in $(seq 1 15); do xdotool mousemove_relative 12 4; sleep 0.04; done
xdotool mouseup 1; sleep 2
xdotool key --clearmodifiers ctrl+z; sleep 1
xdotool key --clearmodifiers ctrl+z; sleep 1
step "undo applied"
shot /root/ev4-05-after-undo.png

# --- QUIT ---
xdotool key --clearmodifiers ctrl+q; sleep 3
shot /root/ev4-06-quit-prompt.png
xdotool key --clearmodifiers Tab; sleep 0.3
xdotool key --clearmodifiers Return
sleep 3
kill $KPID $XPID 2>/dev/null
step "done"
cat $LOG
