#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/aiq2.log
: > $LOG
EX=/tmp/squashfs-root
export LD_LIBRARY_PATH="$EX/usr/lib/x86_64-linux-gnu/krita:$EX/usr/lib/x86_64-linux-gnu:$EX/usr/lib"
export QT_PLUGIN_PATH="$EX/usr/plugins:$EX/usr/lib/x86_64-linux-gnu/qt5/plugins"
export QML2_IMPORT_PATH="$EX/usr/lib/x86_64-linux-gnu/qt5/qml"
export XDG_DATA_DIRS="$EX/usr/share:/usr/share"
KR=$EX/usr/bin/krita
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
echo "=== version under Denverton ===" >> $LOG
timeout 400 qemu-x86_64-static -cpu Denverton $KR --version >> $LOG 2>&1
echo "QEMU_VERSION_EXIT=$?" >> $LOG
echo "=== GUI under Denverton ===" >> $LOG
timeout 450 qemu-x86_64-static -cpu Denverton $KR --nosplash /root/test-input.png > /root/aiq2-gui.log 2>&1 &
QPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
echo "WID=$WID" >> $LOG
if [ -n "$WID" ]; then
  sleep 12
  python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/aiq2-gui.png')" 2>/dev/null
  echo "GUI_RENDERED_UNDER_QEMU_APPIMAGE" >> $LOG
  kill $QPID 2>/dev/null
fi
kill $XPID $QPID 2>/dev/null
echo AIQ2_DONE >> $LOG
grep -vE "TCG|warning" $LOG | head -10
