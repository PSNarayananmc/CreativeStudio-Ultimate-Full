#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-kf5.log
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
probe() { timeout 240 $EX/AppRun --version > /root/probe.txt 2>&1; echo "PROBE_$1=$?"; }
probe E0 >> $LOG
for f in $(find $EX/usr/lib -maxdepth 1 -name "libKF5*.so*" -type f | sort); do
  bn=$(basename $f)
  # skip already-stripped (bin stripped earlier in build? these are original → all unstripped)
  strip --strip-unneeded "$f" 2>/dev/null
  probe "$bn" >> $LOG
done
kill $XPID 2>/dev/null
cat $LOG
