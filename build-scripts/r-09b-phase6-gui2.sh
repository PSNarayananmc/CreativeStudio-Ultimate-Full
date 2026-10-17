#!/bin/bash
# r-09b-phase6-gui2.sh — autosave (correct key) + crash + recovery prompt + autosave content check
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p6/gui2.results
: > $LOG
step() { echo "[$(date +%H:%M:%S)] $1" >> $LOG; }

mkdir -p /root/.config
cat > /root/.config/kritarc <<'EOF'
[General]
AutoSaveInterval=1
askForAutosaveRecovery=true
[theme]
Theme=Creative Studio Dark
EOF

python3 - <<'PY'
from PIL import Image, ImageDraw
img = Image.new("RGB", (1024, 768), (255, 255, 255))
img.save("/root/rec-input.png")
PY
rm -f /root/.rec-input-autosave.kra~ /root/rec-input.kra~ /root/.rec-input.kra~

EX=/tmp/squashfs-root
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3

timeout 900 $EX/AppRun --nosplash /root/rec-input.png > /root/p6/rec-run.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 1
done
sleep 8
xdotool windowfocus $WID; sleep 1
xdotool key --clearmodifiers b; sleep 2
xdotool mousemove 512 384; xdotool mousedown 1
for i in $(seq 1 25); do xdotool mousemove_relative 14 8; sleep 0.04; done
xdotool mouseup 1; sleep 2
step "stroke painted; waiting 85s for autosave"
sleep 85
AS=$(find /root -maxdepth 3 \( -name "*autosave*" -o -name "*.kra~" \) 2>/dev/null | head -3)
echo "RESULT: gui_autosave_file = $(if [ -n "$AS" ]; then echo PASS; else echo FAIL; fi) file=$AS" >> $LOG
ASFILE=$(echo "$AS" | head -1)
step "killing krita with SIGKILL (crash simulation)"
kill -9 $KPID 2>/dev/null
sleep 3

# --- content check of autosave file via runner ---
if [ -n "$ASFILE" ]; then
cat > /root/p6/ascheck.py <<PYEOF
from krita import *
import sys
R = open("/root/p6/gui2.results", "a")
K = Application
doc = K.openDocument("$ASFILE")
if doc:
    nodes = doc.topLevelNodes()
    pd = None
    for n in nodes:
        try:
            pd = bytes(n.projectionPixelData(0, 0, 800, 600))
            break
        except Exception:
            pd = bytes(n.pixelData(0, 0, 800, 600))
            break
    dark = sum(1 for i in range(0, len(pd), 400) if pd[i] < 100)
    R.write("RESULT: autosave_content_has_stroke = %s (dark_samples=%d)\n" % ("PASS" if dark > 5 else "FAIL", dark))
else:
    R.write("RESULT: autosave_content_has_stroke = FAIL (doc did not open)\n")
R.flush(); R.close()
PYEOF
export LD_LIBRARY_PATH="$EX/usr/lib/x86_64-linux-gnu/krita:$EX/usr/lib/x86_64-linux-gnu:$EX/usr/lib"
export QT_PLUGIN_PATH="$EX/usr/plugins:$EX/usr/lib/x86_64-linux-gnu/qt5/plugins"
export QML2_IMPORT_PATH="$EX/usr/lib/x86_64-linux-gnu/qt5/qml:$EX/usr/lib/qml"
export XDG_DATA_DIRS="$EX/usr/share:/usr/share"
export XDG_CONFIG_DIRS="$EX/etc/xdg:/etc/xdg"
cd /root/p6
PYTHONPATH=/root/p6 timeout 300 $EX/usr/bin/kritarunner --script ascheck.py > /root/p6/ascheck.log 2>&1
echo "ASCHECK_EXIT=$?" >> $LOG
fi

# --- recovery prompt on relaunch ---
timeout 900 $EX/AppRun --nosplash /root/rec-input.png > /root/p6/rec-run2.log 2>&1 &
KPID2=$!
WID2=""
for i in $(seq 1 60); do
  WID2=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID2" ] && break
  sleep 1
done
sleep 6
DIALOG=$(xdotool search --name "autosave" 2>/dev/null | head -1)
[ -z "$DIALOG" ] && DIALOG=$(xdotool search --name "Autosave" 2>/dev/null | head -1)
echo "RESULT: recovery_dialog_detected = $(if [ -n "$DIALOG" ]; then echo PASS; else echo FAIL; fi) (wid=$DIALOG)" >> $LOG
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/p6/g-04-recovery-dialog.png')" 2>/dev/null
if [ -n "$DIALOG" ]; then
  xdotool windowfocus $DIALOG; sleep 1
  xdotool key --clearmodifiers Return; sleep 8
  python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/p6/g-05-after-recovery.png')" 2>/dev/null
  step "recovery dialog accepted (Return)"
fi
kill $KPID2 2>/dev/null
kill $XPID 2>/dev/null
echo "GUI2_DONE" >> $LOG
cat $LOG
