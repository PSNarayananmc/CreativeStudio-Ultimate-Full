#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/ai-qemu.log
: > $LOG
set_fake_self() { rm -f /proc/self/exe; ln -sf "$1" /proc/self/exe; }
AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
rm -rf /tmp/squashfs-root
set_fake_self "$AI"
cd /tmp
$AI --appimage-extract >> $LOG 2>&1
EX=/tmp/squashfs-root
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
echo "=== krita --version under Denverton (no AVX) ===" >> $LOG
timeout 400 qemu-x86_64-static -cpu Denverton $EX/AppRun --version >> $LOG 2>&1
echo "QEMU_VERSION_EXIT=$?" >> $LOG
echo "=== full GUI under Denverton ===" >> $LOG
timeout 500 qemu-x86_64-static -cpu Denverton $EX/AppRun --nosplash /root/test-input.png > /root/aiq-gui.log 2>&1 &
QPID=$!
WID=""
for i in $(seq 1 60); do
  WID=$(xdotool search --class krita 2>/dev/null | tail -1)
  [ -n "$WID" ] && break
  sleep 2
done
echo "WID=$WID" >> $LOG
if [ -n "$WID" ]; then
  sleep 10
  python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/aiq-gui.png')" 2>/dev/null
  echo "GUI_RENDERED_UNDER_QEMU" >> $LOG
  kill $QPID 2>/dev/null
fi
kill $XPID 2>/dev/null
echo "=== glibc ceiling in bundle ===" >> $LOG
for f in $(find $EX/usr/lib $EX/usr/lib/x86_64-linux-gnu -maxdepth 1 -type f -o -maxdepth 1 -type l 2>/dev/null | head -200); do
  objdump -T "$f" 2>/dev/null | grep -oP 'GLIBC_[0-9.]+'
done | sort -uV >> $LOG
kill $QPID $XPID 2>/dev/null
echo AIQEMU_DONE >> $LOG
cat $LOG
