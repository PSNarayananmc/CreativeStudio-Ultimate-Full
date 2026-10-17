#!/bin/bash
# r-11-optimize.sh — runs INSIDE chroot: Phase 7 size optimization + Phase 4 tuned config bake
set -e
AI=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
LOG=/root/p7-optimize.log
: > $LOG
step() { echo "[$(date +%H:%M:%S)] $1" >> $LOG; }

step "extract original"
rm -rf /tmp/opt-root /tmp/new.sqsh /tmp/runtime.bin /tmp/new-appimage
cd /tmp
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
timeout 300 $AI --appimage-extract > /dev/null 2>&1
rm -rf /tmp/opt-root && mv /tmp/squashfs-root /tmp/opt-root
DU0=$(du -sm /tmp/opt-root | cut -f1)
step "extracted $DU0 MB"

step "strip: SKIPPED by decision — stripping triggers env-sensitive startup segfaults (KCrash/I18n confirmed culprits; combination still unstable). Size priority is secondary to reliability per spec."
N=0

step "prune dev-only resources"
rm -rf /tmp/opt-root/usr/include
# docs: keep only license/legal files
find /tmp/opt-root/usr/share/doc -type f ! -iname "*copyright*" ! -iname "LICENSE*" ! -iname "COPYING*" -delete 2>/dev/null || true
find /tmp/opt-root/usr/share/doc -type d -empty -delete 2>/dev/null || true
find /tmp/opt-root -name "*.prl" -delete 2>/dev/null || true
find /tmp/opt-root -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
DU1=$(du -sm /tmp/opt-root | cut -f1)
step "after prune: $DU1 MB"

step "bake Phase 4 tuned low-spec config (root-group keys BEFORE sections)"
KRC=/tmp/opt-root/usr/etc/xdg/kritarc
if [ -f "$KRC" ]; then
  T=$(mktemp)
  cat > "$T" <<'EOF'
# Creative Studio Ultimate — low-spec profile (Intel J1800-class, 4 GB RAM)
# Tuned defaults: memory ceilings, thread cap, swap discipline, undo bound.
# Users can override any of these in ~/.config/kritarc (root group, no section header).
memoryHardLimitPercent=35
memorySoftLimitPercent=2
maxNumberOfThreads=2
maxSwapSize=2048
undoStackLimit=100
EOF
  cat "$KRC" >> "$T"
  mv "$T" "$KRC"
  step "config baked into usr/etc/xdg/kritarc"
else
  step "WARN no kritarc found"
fi
mkdir -p /tmp/opt-root/usr/share/creative-studio
cat > /tmp/opt-root/usr/share/creative-studio/LOWMEM-PROFILE.conf <<'EOF'
# Creative Studio Ultimate — low-memory profile reference
# Copy any of these keys into the ROOT group (top of file, no [section]) of
# ~/.config/kritarc to further reduce memory usage on constrained machines.
#
# memoryHardLimitPercent=25   # hard cap on Krita tile memory (% of system RAM)
# memorySoftLimitPercent=2    # soft cap: swtch to swap beyond this
# memoryPoolLimitPercent=0    # disable memory pools
# maxNumberOfThreads=1        # single-threaded image processing (lowest CPU/AM)
# maxSwapSize=1024            # cap swap file size in MiB
# undoStackLimit=50           # cap undo history entries (less RAM per session)
# useCumulativeUndoRedo=true  # merge repeated undo ops (big memory saver for strokes)
EOF
step "lowmem profile doc added"

step "mksquashfs (xz, 1M blocks, max dict)"
cd /tmp
mksquashfs /tmp/opt-root /tmp/new.sqsh -comp zstd -Xcompression-level 19 -b 1M -all-root -noappend -quiet -no-progress 2>>/tmp/mksq-err.log
SQ=$(stat -c %s /tmp/new.sqsh)
step "squashfs built: $SQ bytes"

step "carve runtime + patch digest_md5 + assemble"
python3 - <<'PY'
import struct, hashlib
f = open("/out/CreativeStudio-Ultimate-Full-x86_64.AppImage", "rb")
head = f.read(4096)
e_shoff = struct.unpack("<Q", head[0x28:0x30])[0]
e_shentsize = struct.unpack("<H", head[0x3A:0x3C])[0]
e_shnum = struct.unpack("<H", head[0x3C:0x3E])[0]
rt_size = e_shoff + e_shentsize * e_shnum   # true runtime ELF size
f.seek(0)
rt = bytearray(f.read(rt_size))
f.close()
sq = open("/tmp/new.sqsh", "rb").read()
assert sq[:4] == b"hsqs", "bad squashfs"
md5 = hashlib.md5(sq).digest()
rt[0xe3900:0xe3910] = md5      # patch .digest_md5
out = bytes(rt) + sq
open("/out/optimized.AppImage", "wb").write(out)
import os
os.chmod("/out/optimized.AppImage", 0o755)
print("RT_SIZE=%d SQ_SIZE=%d TOTAL=%d" % (rt_size, len(sq), len(out)))
PY
step "assembled"

OUT=/out/CreativeStudio-Ultimate-Full-x86_64.AppImage
OLD=$(stat -c %s $AI)
NEW=$(stat -c %s /tmp/new-appimage)
cp /tmp/new-appimage /out/optimized.AppImage
chmod +x /out/optimized.AppImage
echo "RESULT: old_size=$OLD new_size=$NEW delta=$((OLD-NEW)) saved_pct=$(( (OLD-NEW)*100/OLD ))" >> $LOG
echo "P7_OPTIMIZE_DONE" >> $LOG
cat $LOG
