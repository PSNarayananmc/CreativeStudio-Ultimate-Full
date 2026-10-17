#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-restore.log
: > $LOG
AI=/out/optimized.AppImage
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/sq-opt
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
if [ ! -d /tmp/squashfs-root/usr/bin ]; then
  rm -f /proc/self/exe; ln -sf /out/CreativeStudio-Ultimate-Full-x86_64.AppImage /proc/self/exe
  timeout 300 /out/CreativeStudio-Ultimate-Full-x86_64.AppImage --appimage-extract > /dev/null 2>&1
fi
sleep 5
EX=/tmp/sq-opt
ORG=/tmp/squashfs-root
probe() { timeout 240 $EX/AppRun --version > /root/probe.txt 2>&1; echo "PROBE_$1=$?"; }
probe F0_broken_baseline >> $LOG
restore() { local pat="$1"; local n=0; for f in $(find $ORG -path "$pat" -type f); do local rel="${f#$ORG/}"; cp "$f" "$EX/$rel"; n=$((n+1)); done; echo "restored_$pat=$n" >> $LOG; }
restore "*/usr/lib/libkrita*.so*"
probe F1_krita_restored >> $LOG
restore "*/usr/lib/libQt5*.so*"
probe F2_qt_restored >> $LOG
restore "*/usr/lib/x86_64-linux-gnu/*"
probe F3_x8664_restored >> $LOG
restore "*/usr/lib/*"
probe F4_allusrlib_restored >> $LOG
restore "*/usr/plugins/*"
probe F5_plugins_restored >> $LOG
kill $XPID 2>/dev/null
cat $LOG
