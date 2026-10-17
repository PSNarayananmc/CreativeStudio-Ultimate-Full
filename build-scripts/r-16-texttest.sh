#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p6-text.log
: > $LOG
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
EX=/tmp/squashfs-root
sleep 5
python3 -c "
from PIL import Image
Image.new('RGB', (1024, 768), (255, 255, 255)).save('/root/tt-input.png')
"
timeout 600 $EX/AppRun --nosplash /root/tt-input.png > /root/tt.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
sleep 8
xdotool windowfocus $WID; sleep 1
# text tool via T shortcut, click canvas, type
xdotool key --clearmodifiers t; sleep 2
xdotool mousemove 400 300; xdotool click 1; sleep 2
xdotool type --delay 60 "Creative Studio"; sleep 3
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/p6-text-typed.png')" 2>/dev/null
# commit text (Escape) and save + export for pixel check
xdotool key --clearmodifiers Escape; sleep 2
xdotool key --clearmodifiers ctrl+shift+s; sleep 6
xdotool type --delay 30 "/root/tt-saved.kra"; sleep 1
xdotool key --clearmodifiers Return; sleep 15
ls -la /root/tt-saved.kra >> $LOG 2>&1
kill $KPID 2>/dev/null; kill $XPID 2>/dev/null
echo "TEXT_TEST_DONE" >> $LOG
# verify: kra has a vector/text layer
python3 - <<'PY' >> $LOG 2>&1
import zipfile, os
if os.path.exists("/root/tt-saved.kra"):
    z = zipfile.ZipFile("/root/tt-saved.kra")
    m = z.read("maindoc.xml").decode(errors="replace")
    names = [n for n in z.namelist() if "layers" in n]
    print("KRA_OK layers_in_xml=%d" % m.upper().count("<LAYER"))
    print("LAYER_FILES=%s" % [n for n in names][:6])
    shp = [n for n in z.namelist() if n.endswith(".shp") or "shape" in n.lower()]
    print("SHAPE_DATA=%s" % shp[:6])
else:
    print("KRA_MISSING")
PY
cat $LOG
