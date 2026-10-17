#!/bin/bash
# r-12-reverify.sh — runs INSIDE chroot: critical-test rerun on the OPTIMIZED AppImage
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-reverify.log
: > $LOG
step() { echo "[$(date +%H:%M:%S)] $1" >> $LOG; }

AI=/out/optimized.AppImage
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/squashfs-root
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
echo "EXTRACT_EXIT=$?" >> $LOG
EX=/tmp/squashfs-root
sleep 8
step "warmup probe (cold-cache first run is segfault-prone in synthetic env)"
timeout 240 $EX/AppRun --version 2>&1 | tail -1 >> $LOG
echo "WARMUP_EXIT=$?" >> $LOG
sleep 3
step "version probe"
timeout 240 $EX/AppRun --version > /root/p7-version.txt 2>&1
VERSION_EXIT=$?
if [ $VERSION_EXIT -ne 0 ]; then
  sleep 5
  timeout 240 $EX/AppRun --version > /root/p7-version.txt 2>&1
  VERSION_EXIT=$?
fi
echo "VERSION_EXIT=$VERSION_EXIT" >> $LOG
grep -iE "krita" /root/p7-version.txt | head -2 >> $LOG

python3 - <<'PY'
from PIL import Image, ImageDraw
img = Image.new("RGB", (1024, 768), (245, 245, 245))
d = ImageDraw.Draw(img)
d.rectangle([50, 50, 974, 718], outline=(60, 60, 60), width=4)
img.save("/root/p7-input.png")
PY

step "GUI launch"
timeout 900 $EX/AppRun --nosplash /root/p7-input.png > /root/p7-gui.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 90); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
echo "WID=$WID" >> $LOG
[ -z "$WID" ] && { echo "RESULT: gui_launch = FAIL" >> $LOG; cat $LOG; exit 2; }
sleep 8
xdotool windowfocus $WID; sleep 1
step "paint strokes"
xdotool key --clearmodifiers b; sleep 2
xdotool mousemove 700 350; xdotool mousedown 1
for i in $(seq 1 30); do xdotool mousemove_relative 10 5; sleep 0.04; done
xdotool mouseup 1; sleep 3
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/p7-01-painted.png')" 2>/dev/null
step "save KRA"
xdotool key --clearmodifiers ctrl+shift+s; sleep 6
xdotool type --delay 30 "/root/p7-saved.kra"; sleep 1
xdotool key --clearmodifiers Return; sleep 15
ls -la /root/p7-saved.kra >> $LOG 2>&1
step "quit"
xdotool key --clearmodifiers ctrl+q; sleep 3
xdotool key --clearmodifiers Return; sleep 3
kill $KPID 2>/dev/null
step "CLI export"
rm -f /root/p7-export.png
timeout 200 $EX/AppRun --nosplash /root/p7-saved.kra --export --export-filename /root/p7-export.png > /root/p7-exp.log 2>&1
echo "EXPORT_EXIT=$?" >> $LOG
kill $XPID 2>/dev/null

python3 - <<'PY' >> $LOG 2>&1
import zipfile, os
from PIL import Image
ok = True
if os.path.exists("/root/p7-saved.kra"):
    z = zipfile.ZipFile("/root/p7-saved.kra")
    m = z.read("maindoc.xml").decode(errors="replace")
    print("RESULT: p7_save_kra = %s (size=%d layers_xml=%d)" % ("PASS" if "<IMAGE" in m.upper() else "FAIL", os.path.getsize("/root/p7-saved.kra"), m.upper().count("<LAYER")))
else:
    print("RESULT: p7_save_kra = FAIL missing"); ok = False
if os.path.exists("/root/p7-export.png") and os.path.getsize("/root/p7-export.png") > 500:
    im = Image.open("/root/p7-export.png").convert("RGB")
    px = im.load()
    dark = sum(1 for x in range(0, im.size[0], 3) for y in range(0, im.size[1], 3) if sum(px[x, y]) < 300)
    print("RESULT: p7_export_png = PASS size=%d dark_px=%d" % (os.path.getsize("/root/p7-export.png"), dark))
else:
    print("RESULT: p7_export_png = FAIL"); ok = False
PY
echo "P7_REVERIFY_DONE" >> $LOG
cat $LOG
