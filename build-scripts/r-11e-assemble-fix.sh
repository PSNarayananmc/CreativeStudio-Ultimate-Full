#!/bin/bash
# r-11e-assemble-fix.sh — runs INSIDE chroot: correct runtime carving + assembly
set -e
AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
LOG=/root/p7-assemble.log
: > $LOG
[ -f /tmp/new.sqsh ] || { echo "NO_NEW_SQSH" >> $LOG; cat $LOG; exit 1; }

python3 - <<'PY'
import struct, hashlib
f = open("/out/CreativeStudio-Ultimate-Full-x86_64.AppImage", "rb")
head = f.read(4096)
e_shoff = struct.unpack("<Q", head[0x28:0x30])[0]
e_shentsize = struct.unpack("<H", head[0x3A:0x3C])[0]
e_shnum = struct.unpack("<H", head[0x3C:0x3E])[0]
elf_end = e_shoff + e_shentsize * e_shnum
f.seek(0)
rt = bytearray(f.read(elf_end))
f.close()
sq = open("/tmp/new.sqsh", "rb").read()
assert sq[:4] == b"hsqs", "bad squashfs"
md5 = hashlib.md5(sq).digest()
rt[0xe3900:0xe3910] = md5
out = bytes(rt) + sq
open("/out/optimized.AppImage", "wb").write(out)
import os
os.chmod("/out/optimized.AppImage", 0o755)
print("RT_SIZE=%d SQ_SIZE=%d TOTAL=%d" % (elf_end, len(sq), len(out)))
PY
echo "ASSEMBLE_DONE" >> $LOG
cat $LOG
