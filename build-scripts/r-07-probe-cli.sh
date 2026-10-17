#!/bin/bash
export HOME=/root
export DISPLAY=:77
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
EX=/tmp/squashfs-root
if [ ! -d $EX ]; then
  rm -f /proc/self/exe; ln -sf /out/CreativeStudio-Ultimate-Full-x86_64.AppImage /proc/self/exe
  cd /tmp && timeout 240 /out/CreativeStudio-Ultimate-Full-x86_64.AppImage --appimage-extract > /dev/null 2>&1
fi
echo "=== AppRun --version (with X up) ==="
timeout 240 $EX/AppRun --version 2>&1 | head -3
echo "VERSION_EXIT=$?"
echo "=== kritarunner --help ==="
timeout 120 $EX/AppRun kritarunner --help 2>&1 | head -25
echo "=== krita --help (export opts) ==="
timeout 120 $EX/AppRun krita --help 2>&1 | grep -E 'export|script|version' | head -10
kill $XPID 2>/dev/null
