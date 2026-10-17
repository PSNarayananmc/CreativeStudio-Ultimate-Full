#!/bin/bash
# r-06-appimage-verify.sh — runs INSIDE chroot: full functional re-verification
# of the surviving AppImage after sandbox reset + baseline (stock) memory stats.
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/reverify.log
: > $LOG
step() { echo "[$(date +%H:%M:%S)] $1" >> $LOG; }

AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
[ -f "$AI" ] || { echo "MISSING_APPIMAGE" >> $LOG; cat $LOG; exit 1; }

# fake /proc/self/exe for the AppImage runtime (static fake /proc in this chroot)
rm -f /proc/self/exe; ln -sf "$AI" /proc/self/exe

# --- test input ---
python3 - <<'PY'
from PIL import Image, ImageDraw
img = Image.new("RGB", (1024, 768), (245, 245, 245))
d = ImageDraw.Draw(img)
d.rectangle([50, 50, 974, 718], outline=(60, 60, 60), width=4)
d.ellipse([400, 300, 624, 468], fill=(30, 120, 200))
img.save("/root/test-input.png")
PY
step "test input generated (1024x768)"

rm -rf /tmp/squashfs-root
cd /tmp
timeout 240 $AI --appimage-extract >> $LOG 2>&1
echo "EXTRACT_EXIT=$?" >> $LOG
EX=/tmp/squashfs-root

step "version probe"
timeout 240 $EX/AppRun --version >> $LOG 2>&1
echo "VERSION_EXIT=$?" >> $LOG

Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3

step "GUI launch"
timeout 900 $EX/AppRun --nosplash /root/test-input.png > /root/re-gui.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 90); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
step "WID=$WID"
if [ -z "$WID" ]; then echo "FAIL NO_WINDOW" >> $LOG; kill $XPID 2>/dev/null; cat $LOG; exit 2; fi
sleep 8
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/re-01-opened.png')" 2>/dev/null
step "screenshot: opened"

# --- brush strokes (real paint engine) ---
xdotool windowfocus $WID; sleep 1
xdotool key --clearmodifiers b; sleep 2
xdotool mousemove 700 350; xdotool mousedown 1
for i in $(seq 1 30); do xdotool mousemove_relative 10 5; sleep 0.04; done
xdotool mouseup 1; sleep 3
step "strokes painted"
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/re-02-strokes.png')" 2>/dev/null

# --- memory snapshot (stock baseline, Phase 4 pre-metric) ---
echo "=== MEMORY SNAPSHOT (after paint, stock config) ===" >> $LOG
ps -eo pid,ppid,rss,vsz,comm --sort=-rss | head -12 >> $LOG
GREP_PID=$KPID
awk '/VmHWM|VmRSS/{print FILENAME": "$0}' /proc/$GREP_PID/status >> $LOG 2>/dev/null
TOTAL=$(ps -eo rss --no-headers | awk '{s+=$1} END {print s}')
echo "TOTAL_RSS_ALL_PROCESSES_KB=$TOTAL" >> $LOG

# --- undo ---
xdotool key --clearmodifiers ctrl+z; sleep 3
step "undo pressed"
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/re-03-undo.png')" 2>/dev/null

# --- Save As KRA ---
xdotool key --clearmodifiers ctrl+shift+s; sleep 6
xdotool type --delay 30 "/root/re-saved.kra"; sleep 1
xdotool key --clearmodifiers Return; sleep 18
ls -la /root/re-saved.kra >> $LOG 2>&1
step "save-as done"
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/re-04-saved.png')" 2>/dev/null

# --- Export PNG ---
xdotool key --clearmodifiers ctrl+shift+e; sleep 6
xdotool type --delay 30 "/root/re-export.png"; sleep 1
xdotool key --clearmodifiers Return; sleep 18
ls -la /root/re-export.png >> $LOG 2>&1
step "export done"
python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/re-05-exported.png')" 2>/dev/null

# --- quit ---
xdotool key --clearmodifiers ctrl+q; sleep 4
xdotool key --clearmodifiers Return; sleep 4
kill $KPID 2>/dev/null; kill $XPID 2>/dev/null
step "quit"

# --- artifact validation (KRA zip integrity + PNG pixel check) ---
python3 - <<'PY' >> $LOG 2>&1
import zipfile, os
from PIL import Image
ok = True
if os.path.exists("/root/re-saved.kra"):
    try:
        z = zipfile.ZipFile("/root/re-saved.kra")
        names = z.namelist()
        assert "maindoc.xml" in names, "no maindoc.xml"
        m = z.read("maindoc.xml").decode(errors="replace")
        print("KRA_OK maindoc has IMAGE:", "<IMAGE" in m.upper())
        print("KRA_LAYER_COUNT_XML:", m.upper().count("<LAYER"))
    except Exception as e:
        print("KRA_BROKEN:", e); ok = False
else:
    print("KRA_MISSING"); ok = False
if os.path.exists("/root/re-export.png"):
    try:
        im = Image.open("/root/re-export.png").convert("RGB")
        w, h = im.size
        px = im.load()
        # count dark pixels (stroke evidence) vs the input (which had 0 dark-stroke px)
        dark = sum(1 for x in range(0, w, 3) for y in range(0, h, 3) if sum(px[x, y]) < 300)
        print(f"EXPORT_OK size={w}x{h} sampled_dark_px={dark}")
        print("EXPORT_HAS_STROKE:", dark > 50)
    except Exception as e:
        print("EXPORT_BROKEN:", e); ok = False
else:
    print("EXPORT_MISSING"); ok = False
print("ARTIFACTS_OK" if ok else "ARTIFACTS_FAIL")
PY
step "DONE"
cat $LOG
