#!/bin/bash
# r-09a-phase6-gui1.sh — launch timing, brush/eraser switch, GUI undo, autosave file, crash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p6/gui.results
: > $LOG
step() { echo "[$(date +%H:%M:%S)] $1" >> $LOG; }

# user config: autosave every 1 min + recovery prompt + keep theme
mkdir -p /root/.config
cat > /root/.config/kritarc <<'EOF'
[General]
askForAutosaveRecovery=true
[StartPage]
askForAutosaveRecovery=true
[autosave]
autosaveInterval=1
[theme]
Theme=Creative Studio Dark
EOF
step "user config written"

# input image
python3 - <<'PY'
from PIL import Image, ImageDraw
img = Image.new("RGB", (1024, 768), (250, 250, 250))
d = ImageDraw.Draw(img)
d.rectangle([40, 40, 984, 728], outline=(80, 80, 80), width=3)
img.save("/root/gui-input.png")
PY

EX=/tmp/squashfs-root
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3

T0=$(date +%s%3N)
timeout 900 $EX/AppRun --nosplash /root/gui-input.png > /root/p6/gui-run.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 90); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 1
done
T1=$(date +%s%3N)
echo "RESULT: gui_launch_to_window_ms = $((T1 - T0)) (WID=$WID)" >> $LOG
[ -z "$WID" ] && { echo "RESULT: gui_launch = FAIL" >> $LOG; cat $LOG; kill $XPID 2>/dev/null; exit 2; }
sleep 8
xdotool windowfocus $WID; sleep 1

shot() { python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('$1')" 2>/dev/null; }

# brush stroke (black default)
xdotool key --clearmodifiers b; sleep 2
xdotool mousemove 500 300; xdotool mousedown 1
for i in $(seq 1 20); do xdotool mousemove_relative 12 6; sleep 0.04; done
xdotool mouseup 1; sleep 2
shot /root/p6/g-01-brushstroke.png
step "brush stroke done"

# eraser preset switch (E toggles eraser mode on brush)
xdotool key --clearmodifiers e; sleep 2
xdotool mousemove 500 300; xdotool mousedown 1
for i in $(seq 1 20); do xdotool mousemove_relative 12 6; sleep 0.04; done
xdotool mouseup 1; sleep 2
shot /root/p6/g-02-eraserstroke.png
step "eraser stroke done"
python3 - <<'PY' >> $LOG 2>&1
from PIL import Image
a = Image.open("/root/p6/g-01-brushstroke.png").convert("L")
b = Image.open("/root/p6/g-02-eraserstroke.png").convert("L")
diff = sum(1 for x in range(400, 1500, 6) for y in range(250, 700, 6) if abs(a.getpixel((x, y)) - b.getpixel((x, y))) > 10)
print("RESULT: gui_eraser_switch_changed_canvas = %s (diff_px=%d)" % ("PASS" if diff > 20 else "FAIL", diff))
PY

# GUI undo
xdotool key --clearmodifiers ctrl+z; sleep 3
shot /root/p6/g-03-afterundo.png
step "undo done"
python3 - <<'PY' >> $LOG 2>&1
from PIL import Image
a = Image.open("/root/p6/g-02-eraserstroke.png").convert("L")
b = Image.open("/root/p6/g-03-afterundo.png").convert("L")
diff = sum(1 for x in range(400, 1500, 6) for y in range(250, 700, 6) if abs(a.getpixel((x, y)) - b.getpixel((x, y))) > 10)
print("RESULT: gui_undo_changed_canvas = %s (diff_px=%d)" % ("PASS" if diff > 20 else "FAIL", diff))
PY

# autosave: wait > 1 min with open doc
step "waiting 80s for autosave tick"
sleep 80
find /root -maxdepth 3 -name "*autosave*" -o -name "*.kra~" 2>/dev/null > /tmp/asfiles.txt
echo "RESULT: gui_autosave_file_created = $(if [ -s /tmp/asfiles.txt ]; then echo PASS; else echo FAIL; fi) files=$(tr '\n' ' ' < /tmp/asfiles.txt)" >> $LOG

# crash: SIGKILL mid-session
kill -9 $KPID 2>/dev/null
sleep 3
step "krita killed with SIGKILL"
kill $XPID 2>/dev/null
echo "GUI1_DONE" >> $LOG
cat $LOG
