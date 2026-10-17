#!/bin/bash
# r-08h-phase6-cli-export2.sh — single-format CLI export: $1 = extension
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
EX=/tmp/squashfs-root
SRC=/root/p6/rt.kra
OUT=/root/p6/cli.tiff
rm -f $OUT
timeout 130 $EX/AppRun --nosplash $SRC --export --export-filename $OUT > /root/p6/cli-out.log 2>&1
EC=$?
SZ=$(stat -c %s $OUT 2>/dev/null || echo 0)
if [ $EC -eq 0 ] && [ $SZ -gt 500 ]; then
  echo "EXPORT_OK size=$SZ"
else
  echo "EXPORT_FAIL exit=$EC size=$SZ"
  tail -4 /root/p6/cli-out.log
fi
kill $XPID 2>/dev/null
pkill -f "usr/bin/krita" 2>/dev/null
