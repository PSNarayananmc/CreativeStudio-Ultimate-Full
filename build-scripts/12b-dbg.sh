#!/bin/bash
set_fake_self() { rm -f /proc/self/exe; ln -sf "$1" /proc/self/exe; }
AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
set_fake_self "$AI"
echo "=== --appimage-extract direct ==="
cd /tmp && timeout 120 $AI --appimage-extract 2>&1 | head -4
echo "=== appimagetool help (compression opts) ==="
set_fake_self /tools/squashfs-root/usr/bin/appimagetool
/tools/squashfs-root/usr/bin/appimagetool --help 2>&1 | grep -iE "comp|gzip|xz|zstd|squashfs" | head -6
echo "=== which mksquashfs did it use ==="
which mksquashfs; mksquashfs -version 2>&1 | head -1
