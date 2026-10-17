#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
EX=/tmp/squashfs-root
sleep 5
timeout 600 $EX/AppRun --nosplash /root/tt-input.png > /root/tt2.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
sleep 8
xdotool windowfocus $WID; sleep 1
# Text tool = 2nd icon in toolbox (approx 294,190); click it
xdotool mousemove 294 190; xdotool click 1; sleep 2
xdotool key --clearmodifiers Escape; sleep 1
# click on canvas to place text cursor
xdotool mousemove 500 350; xdotool click 1; sleep 2
xdotool type --delay 80 "Creative Studio"; sleep 3
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/p6b-text-typed.png')" 2>/dev/null
xdotool key --clearmodifiers ctrl+shift+s; sleep 6
xdotool type --delay 30 "/root/tt2-saved.kra"; sleep 1
xdotool key --clearmodifiers Return; sleep 15
kill $KPID 2>/dev/null; kill $XPID 2>/dev/null
python3 - <<'PY'
import zipfile, os
if os.path.exists("/root/tt2-saved.kra"):
    z = zipfile.ZipFile("/root/tt2-saved.kra")
    m = z.read("maindoc.xml").decode(errors="replace")
    shp = [n for n in z.namelist() if n.endswith(".shp")]
    print("RESULT: text_layer_saved = %s layers=%d shape_files=%s" % ("PASS" if shp else "FAIL", m.upper().count("<LAYER"), shp[:4]))
else:
    print("RESULT: text_layer_saved = FAIL (no kra)")
PY
