#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
OUT=/root/qemu-results.txt
: > $OUT
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
echo "=== TEST 1: krita --version under Silvermont emulation (SSE4.2, no AVX, no FMA) ===" >> $OUT
timeout 240 qemu-x86_64-static -cpu Denverton /krita-stage/bin/krita --version >> $OUT 2>&1
echo "T1_EXIT=$?" >> $OUT
echo "=== TEST 2: full GUI + brush paint under Silvermont ===" >> $OUT
timeout 500 qemu-x86_64-static -cpu Denverton /krita-stage/bin/krita --nosplash /root/test-input.png > /root/qemu-gui.log 2>&1 &
QPID=$!
WID=""
for i in $(seq 1 90); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
echo "WID=$WID" >> $OUT
if [ -n "$WID" ]; then
  sleep 8
  xdotool windowfocus $WID 2>/dev/null; sleep 1
  xdotool key --clearmodifiers b; sleep 2
  xdotool mousemove 700 350; xdotool mousedown 1
  for i in $(seq 1 25); do xdotool mousemove_relative 10 6; sleep 0.05; done
  xdotool mouseup 1
  sleep 5
  python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/qemu-paint.png')" 2>/dev/null
  echo "PAINT_ATTEMPTED" >> $OUT
  kill $QPID 2>/dev/null
fi
kill $XPID 2>/dev/null
echo QEMU_TEST_DONE >> $OUT
cat $OUT
