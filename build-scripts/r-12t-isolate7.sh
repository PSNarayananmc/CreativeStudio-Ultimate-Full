#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR /root/kf5-orig
LOG=/root/p7-iso7.log
: > $LOG
AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/squashfs-root
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
sleep 5
EX=/tmp/squashfs-root
LIBS="libKF5Crash.so.5 libKF5GuiAddons.so.5 libKF5I18n.so.5 libKF5ItemViews.so.5 libKF5KDcraw.so.5 libKF5WidgetsAddons.so.5 libKF5WindowSystem.so.5"
for L in $LIBS; do cp "$EX/usr/lib/$L" "/root/kf5-orig/$L"; done
probe() { timeout 240 $EX/AppRun --version > /root/probe.txt 2>&1; echo "PROBE_$1=$?"; }
for L in $LIBS; do
  # restore all, strip only $L
  for R in $LIBS; do cp "/root/kf5-orig/$R" "$EX/usr/lib/$R"; done
  strip --strip-unneeded "$EX/usr/lib/$L" 2>/dev/null
  probe "iso_$L" >> $LOG
done
# restore all pristine
for R in $LIBS; do cp "/root/kf5-orig/$R" "$EX/usr/lib/$R"; done
kill $XPID 2>/dev/null
cat $LOG
