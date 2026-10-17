#!/bin/bash
AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/sq-orig
cd /tmp && timeout 300 $AI --appimage-extract > /dev/null 2>&1
mv /tmp/squashfs-root /tmp/sq-orig
echo "=== license files in ORIGINAL payload ==="
find /tmp/sq-orig/usr/share/doc/krita* /tmp/sq-orig/usr/share/krita -maxdepth 2 -iname "COPYING*" -o -maxdepth 2 -iname "LICENSE*" 2>/dev/null | head -10
ls /tmp/sq-orig/usr/share/doc/ | grep -i krita
find /tmp/sq-orig -maxdepth 3 -iname "COPYING*" | head -8
