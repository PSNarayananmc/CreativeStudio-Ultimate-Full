#!/bin/bash
# r-12n-stripbisect.sh — bisect which stripped component breaks file-redirect probes
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-bisect.log
: > $LOG
AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
sleep 8
EX=/tmp/squashfs-root
strip_group() {
  local pat="$1"
  local n=0
  for f in $pat; do
    [ -f "$f" ] || continue
    strip --strip-unneeded "$f" 2>/dev/null && n=$((n+1))
  done
  echo "$n"
}
probe() {
  timeout 240 $EX/AppRun --version > /root/probe.txt 2>&1
  echo "PROBE_$1=$?"
}
# B0: pristine control
probe B0 >> $LOG
# B1: strip executables only
N=$(strip_group "$EX/usr/bin/*")
echo "stripped_bin=$N" >> $LOG
probe B1 >> $LOG
# B2: restore bin from fresh extract? (no restore possible; continue accumulating)
# B2: strip krita core libs
N=$(strip_group "$EX/usr/lib/libkrita"*.so*)
echo "stripped_libkrita=$N" >> $LOG
probe B2 >> $LOG
# B3: strip krita plugins dir libs
N=$(strip_group "$EX/usr/lib/x86_64-linux-gnu/krita/"*.so*)
echo "stripped_kritapluginlibs=$N" >> $LOG
probe B3 >> $LOG
# B4: strip Qt libs
N=$(strip_group "$EX/usr/lib/libQt5"*.so*)
echo "stripped_qt=$N" >> $LOG
probe B4 >> $LOG
# B5: strip KF5 + other x86_64-linux-gnu libs
N=$(strip_group "$EX/usr/lib/x86_64-linux-gnu/"*.so*)
echo "stripped_kf5others=$N" >> $LOG
probe B5 >> $LOG
# B6: strip remaining top-level libs
N=$(strip_group "$EX/usr/lib/"*.so*)
echo "stripped_toplevel_rest=$N" >> $LOG
probe B6 >> $LOG
kill $XPID 2>/dev/null
cat $LOG
