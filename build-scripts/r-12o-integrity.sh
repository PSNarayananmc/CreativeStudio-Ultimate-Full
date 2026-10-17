#!/bin/bash
LOG=/root/p7-integrity.log
: > $LOG
AI=/out/optimized.AppImage
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/sq-opt
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
mv /tmp/squashfs-root /tmp/sq-opt
# original still at /tmp/squashfs-root from previous test? if not, re-extract
if [ ! -d /tmp/squashfs-root/usr/bin ]; then
  rm -f /proc/self/exe; ln -sf /out/CreativeStudio-Ultimate-Full-x86_64.AppImage /proc/self/exe
  timeout 300 /out/CreativeStudio-Ultimate-Full-x86_64.AppImage --appimage-extract > /dev/null 2>&1
fi
echo "=== integrity compare (original vs optimized-extraction) ===" >> $LOG
for f in usr/bin/krita usr/bin/kritarunner usr/lib/libkritaui.so.19 usr/lib/libkritaimage.so.19 usr/lib/libQt5Widgets.so.5 usr/lib/x86_64-linux-gnu/libKF5XmlGui.so.5 usr/share/krita/bundles/RGBA_brushes.bundle usr/etc/xdg/kritarc; do
  A=$(sha256sum "/tmp/squashfs-root/$f" 2>/dev/null | cut -c1-12)
  B=$(sha256sum "/tmp/sq-opt/$f" 2>/dev/null | cut -c1-12)
  # NOTE: optimized tree should differ only where strip/prune applied; binaries stripped => different
  echo "$f orig=$A opt=$B" >> $LOG
done
# count files
echo "orig_files=$(find /tmp/squashfs-root -type f | wc -l) opt_files=$(find /tmp/sq-opt -type f | wc -l)" >> $LOG
cat $LOG
