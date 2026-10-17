#!/bin/bash
# r-08g-phase6-cli-export.sh — validate PNG/JPG/TIFF exports via krita CLI (known-good path)
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
EX=/tmp/squashfs-root
if [ ! -d $EX ]; then
  rm -f /proc/self/exe; ln -sf /out/CreativeStudio-Ultimate-Full-x86_64.AppImage /proc/self/exe
  cd /tmp && timeout 240 /out/CreativeStudio-Ultimate-Full-x86_64.AppImage --appimage-extract > /dev/null 2>&1
fi
SRC=/root/p6/rt.kra
ls -la $SRC
for ext in png jpg tiff; do
  OUT=/root/p6/cli.$ext
  rm -f $OUT
  timeout 150 $EX/AppRun --nosplash $SRC --export-filename $OUT > /root/p6/cli-$ext.log 2>&1
  EC=$?
  SZ=$(stat -c %s $OUT 2>/dev/null || echo 0)
  if [ $EC -eq 0 ] && [ $SZ -gt 500 ]; then
    echo "RESULT: t09c_export_$ext = PASS size=$SZ"
  else
    echo "RESULT: t09c_export_$ext = FAIL exit=$EC size=$SZ"
    tail -3 /root/p6/cli-$ext.log
  fi
done
# also export from PSD source to prove PSD->raster works
timeout 150 $EX/AppRun --nosplash /root/p6/rt.psd --export-filename /root/p6/cli-frompsd.png > /root/p6/cli-psd.log 2>&1
EC=$?; SZ=$(stat -c %s /root/p6/cli-frompsd.png 2>/dev/null || echo 0)
[ $EC -eq 0 ] && [ $SZ -gt 500 ] && echo "RESULT: t08c_psd_to_png = PASS size=$SZ" || echo "RESULT: t08c_psd_to_png = FAIL exit=$EC size=$SZ"
kill $XPID 2>/dev/null
pkill -f "usr/bin/krita" 2>/dev/null
