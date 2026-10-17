#!/bin/bash
LOG=/root/p7-hash.log
: > $LOG
AI=/out/optimized.AppImage
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/sq-opt
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
mv /tmp/squashfs-root /tmp/sq-opt
if [ ! -d /tmp/squashfs-root/usr/bin ]; then
  rm -f /proc/self/exe; ln -sf /out/CreativeStudio-Ultimate-Full-x86_64.AppImage /proc/self/exe
  timeout 300 /out/CreativeStudio-Ultimate-Full-x86_64.AppImage --appimage-extract > /dev/null 2>&1
fi
cd /
(cd /tmp/squashfs-root && find . -type f -exec sha256sum {} + 2>/dev/null | sort -k2) > /tmp/h-org.txt
(cd /tmp/sq-opt && find . -type f -exec sha256sum {} + 2>/dev/null | sort -k2) > /tmp/h-opt.txt
DIFFS=$(diff /tmp/h-org.txt /tmp/h-opt.txt | grep -cE "^[<>]")
echo "TOTAL_DIFF_LINES=$DIFFS" >> $LOG
# files differing (excluding expected: binaries stripped, kritarc, lowmem)
diff /tmp/h-org.txt /tmp/h-opt.txt | grep -E "^[<>]" | awk '{print $1, $3}' | sort -k2 | uniq | head -30 >> $LOG
echo "=== where are krita plugins ===" >> $LOG
find /tmp/squashfs-root -name "*.so" -path "*plugin*" | head -5 >> $LOG
ls /tmp/squashfs-root/usr/plugins/ >> $LOG 2>&1
cat $LOG
