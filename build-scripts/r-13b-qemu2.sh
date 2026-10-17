#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-qemu2.log
: > $LOG
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 5
EX=/tmp/squashfs-root
export LD_LIBRARY_PATH="$EX/usr/lib/x86_64-linux-gnu/krita:$EX/usr/lib/x86_64-linux-gnu:$EX/usr/lib"
export QT_PLUGIN_PATH="$EX/usr/plugins:$EX/usr/lib/x86_64-linux-gnu/qt5/plugins"
export QML2_IMPORT_PATH="$EX/usr/lib/x86_64-linux-gnu/qt5/qml:$EX/usr/lib/qml"
export XDG_DATA_DIRS="$EX/usr/share:/usr/share"
export XDG_CONFIG_DIRS="$EX/etc/xdg:/etc/xdg"
echo "=== QEMU Denverton: krita --version (env set) ===" >> $LOG
timeout 500 qemu-x86_64-static -cpu Denverton $EX/usr/bin/krita --version > /root/qv2.txt 2>&1
echo "QEMU_VERSION_EXIT=$?" >> $LOG
grep -iE "krita [0-9]" /root/qv2.txt | head -2 >> $LOG
echo "=== QEMU Denverton: GUI launch (paint test) ===" >> $LOG
python3 -c "
from PIL import Image, ImageDraw
img = Image.new('RGB', (1024, 768), (250, 250, 250))
img.save('/root/qemu-input.png')
"
timeout 900 qemu-x86_64-static -cpu Denverton $EX/usr/bin/krita --nosplash /root/qemu-input.png > /root/qemu-gui2.log 2>&1 &
QPID=$!
WID=""
for i in $(seq 1 120); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
echo "QEMU_WID=$WID" >> $LOG
if [ -n "$WID" ]; then
  sleep 10
  xdotool windowfocus $WID; sleep 1
  xdotool key --clearmodifiers b; sleep 3
  xdotool mousemove 700 350; xdotool mousedown 1
  for i in $(seq 1 20); do xdotool mousemove_relative 10 5; sleep 0.05; done
  xdotool mouseup 1; sleep 5
  python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/p7-qemu-paint.png')" 2>/dev/null
  echo "QEMU_PAINT_ATTEMPTED" >> $LOG
  kill $QPID 2>/dev/null
else
  echo "QEMU_GUI_NO_WINDOW" >> $LOG
  kill $QPID 2>/dev/null
fi
kill $XPID 2>/dev/null
echo "QEMU2_DONE" >> $LOG
cat $LOG
