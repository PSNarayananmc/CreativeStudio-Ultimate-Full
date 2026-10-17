#!/bin/bash
set -e
LOG=/root/p7-z19.log
: > $LOG
rm -f /tmp/new.sqsh
mksquashfs /tmp/opt-root /tmp/new.sqsh -comp zstd -Xcompression-level 19 -b 1M -all-root -noappend -quiet -no-progress 2>>/tmp/mksq19.log
SQ=$(stat -c %s /tmp/new.sqsh)
echo "SQ19_SIZE=$SQ" >> $LOG
python3 - <<'PY'
import struct, hashlib
f = open("/out/CreativeStudio-Ultimate-Full-x86_64.AppImage", "rb")
head = f.read(4096)
e_shoff = struct.unpack("<Q", head[0x28:0x30])[0]
e_shentsize = struct.unpack("<H", head[0x3A:0x3C])[0]
e_shnum = struct.unpack("<H", head[0x3C:0x3E])[0]
rt_size = e_shoff + e_shentsize * e_shnum
f.seek(0)
rt = bytearray(f.read(rt_size))
f.close()
sq = open("/tmp/new.sqsh", "rb").read()
md5 = hashlib.md5(sq).digest()
rt[0xe3900:0xe3910] = md5
out = bytes(rt) + sq
open("/out/optimized.AppImage", "wb").write(out)
import os
os.chmod("/out/optimized.AppImage", 0o755)
print("TOTAL=%d" % len(out))
PY
echo "Z19_DONE" >> $LOG
cat $LOG
