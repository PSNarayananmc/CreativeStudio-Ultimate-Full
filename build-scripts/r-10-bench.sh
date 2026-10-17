#!/bin/bash
# r-10-bench.sh — runs INSIDE chroot: GUI workload benchmark (stock or tuned via /root/.config/kritarc)
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p6/bench.results
: > $LOG
step() { echo "[$(date +%H:%M:%S)] $1" >> $LOG; }

python3 - <<'PY'
from PIL import Image, ImageDraw
import random
img = Image.new("RGB", (4000, 3000), (255, 255, 255))
d = ImageDraw.Draw(img)
for i in range(60):
    x, y = random.randint(0, 3800), random.randint(0, 2800)
    w, h = random.randint(80, 600), random.randint(80, 600)
    c = (random.randint(0, 255), random.randint(0, 255), random.randint(0, 255))
    if i % 3 == 0: d.rectangle([x, y, x + w, y + h], outline=c, width=6)
    elif i % 3 == 1: d.ellipse([x, y, x + w, y + h], outline=c, width=6)
    else: d.line([x, y, x + w, y + h], fill=c, width=8)
img.save("/root/bench-input.png")
PY
step "bench input 4000x3000 generated"

EX=/tmp/squashfs-root
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3

T0=$(date +%s%3N)
timeout 1200 $EX/AppRun --nosplash /root/bench-input.png > /root/p6/bench-gui.log 2>&1 &
KPID=$!
WID=""
for i in $(seq 1 120); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 1
done
T1=$(date +%s%3N)
echo "BENCH launch_to_window_ms = $((T1 - T0))" >> $LOG
[ -z "$WID" ] && { echo "BENCH launch = FAIL" >> $LOG; cat $LOG; exit 2; }
sleep 12   # document fully loaded

# 30 brush strokes timed
TS=$(date +%s%3N)
xdotool windowfocus $WID; sleep 1
xdotool key --clearmodifiers b; sleep 2
xdotool mousemove 800 400; xdotool mousedown 1
for i in $(seq 1 30); do xdotool mousemove_relative 40 12; sleep 0.03; done
xdotool mouseup 1
sleep 1
xdotool mousemove 1000 600; xdotool mousedown 1
for i in $(seq 1 30); do xdotool mousemove_relative -35 10; sleep 0.03; done
xdotool mouseup 1
sleep 2
TE=$(date +%s%3N)
echo "BENCH strokes_60_ms = $((TE - TS))" >> $LOG
step "strokes done"

# save timed
rm -f /root/bench-saved.kra
TS=$(date +%s%3N)
xdotool key --clearmodifiers ctrl+shift+s; sleep 6
xdotool type --delay 25 "/root/bench-saved.kra"; sleep 1
xdotool key --clearmodifiers Return
for i in $(seq 1 120); do [ -s /root/bench-saved.kra ] && break; sleep 1; done
TE=$(date +%s%3N)
echo "BENCH save_kra_ms = $((TE - TS)) size=$(stat -c %s /root/bench-saved.kra 2>/dev/null || echo 0)" >> $LOG
step "save done"

# undo
xdotool key --clearmodifiers ctrl+z; sleep 2
step "undo done"

# quit + shutdown timing
TQ0=$(date +%s%3N)
xdotool windowfocus $WID; sleep 1
xdotool key --clearmodifiers ctrl+q; sleep 4
xdotool key --clearmodifiers Return; sleep 4
for i in $(seq 1 25); do kill -0 $KPID 2>/dev/null || break; sleep 1; done
TQ1=$(date +%s%3N)
echo "BENCH shutdown_ms = $((TQ1 - TQ0))" >> $LOG
kill $KPID 2>/dev/null
sleep 2

# CLI export timed (separate process)
TS=$(date +%s%3N)
rm -f /root/bench-export.png
timeout 400 $EX/AppRun --nosplash /root/bench-saved.kra --export --export-filename /root/bench-export.png > /root/p6/bench-exp.log 2>&1
TE=$(date +%s%3N)
echo "BENCH export_png_ms = $((TE - TS)) size=$(stat -c %s /root/bench-export.png 2>/dev/null || echo 0)" >> $LOG
kill $XPID 2>/dev/null
echo "BENCH_DONE" >> $LOG
cat $LOG
