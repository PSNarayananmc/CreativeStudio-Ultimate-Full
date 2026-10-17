#!/bin/bash
# r-15-final-repack.sh — runs INSIDE chroot: add GPL compliance docs + final repack
set -e
AI=/out/optimized.AppImage
LOG=/root/p7-final.log
: > $LOG
step() { echo "[$(date +%H:%M:%S)] $1" >> $LOG; }

step "extract current optimized image"
rm -f /proc/self/exe; ln -sf $AI /proc/self/exe
rm -rf /tmp/sq-final
cd /tmp
timeout 300 $AI --appimage-extract > /dev/null 2>&1
mv /tmp/squashfs-root /tmp/sq-final

step "add GPL compliance + product docs"
mkdir -p /tmp/sq-final/usr/share/doc/creative-studio
cp /tmp/gpl-3.0.txt /tmp/sq-final/usr/share/doc/creative-studio/COPYING.GPL-3
cat > /tmp/sq-final/usr/share/doc/creative-studio/SOURCE-CODE-OFFER.txt <<'EOF'
CREATIVE STUDIO ULTIMATE (Full edition) — source code offer
============================================================

This application is built on Krita, copyright the Krita Foundation and
contributors, licensed under the GNU General Public License version 3
(or, at your option, any later version).

Base source code:
  Project : Krita
  Version : 5.2.16
  Commit  : 7d9aefc93f15998eca13458bb9a065e2cca77c02 (tag v5.2.16)
  Upstream: https://invent.kde.org/graphics/krita
            https://github.com/KDE/krita
            https://download.kde.org/stable/krita/5.2.16/

Modifications applied for this distribution (also available on request):
  1. Qt 5.12.8 compatibility patches (forced-include header
     krita_qt512_compat.h + source patches: Qt::SkipEmptyParts,
     QImage::convertTo, QWidget::screen, QPainterPath::clear)
  2. Branding assets: splash screen, start-page banner, desktop entry,
     application icon, color scheme "Creative Studio Dark"
  3. Default configuration: tuned low-spec profile (root-group keys of
     kritarc) and Creative Studio workspace preset

Per GPL section 3, the complete corresponding source for this binary
distribution is available, at no charge, from the upstream repository
above (identical tag) plus the modification list above, for a period of
at least three years from the last distribution of this package.

Bundled third-party libraries retain their own licenses (LGPL, BSD, MIT,
Apache-2.0 etc.); per-package copyright files are preserved under
/usr/share/doc/. See also LicenseList.csv shipped with the pykrita
plugins and the About dialog of the application.
EOF
cat > /tmp/sq-final/usr/share/doc/creative-studio/README-CREATIVE-STUDIO.txt <<'EOF'
CREATIVE STUDIO ULTIMATE (Full edition)
========================================
A professional image studio built on the Krita 5.2.16 paint engine,
packaged as a self-contained AppImage for Ubuntu 20.04 LTS (x86_64)
and compatible distributions (glibc >= 2.31 target, works on newer).

HIGHLIGHTS
- Photoshop-style dark studio theme ("Creative Studio Dark", default)
- Studio workspace preset: left toolbox / center canvas / right dockers
  (Tool Options, Advanced Color Selector, Layers, Brush Presets)
  selectable via --workspace CreativeStudio or Window > Workspace
- Photoshop-compatible keyboard shortcut profile included and
  selectable in Settings > Keyboard Shortcuts
- Full Krita feature set: layers, masks, selections, brushes, filters,
  color management (LCMS/OCIO), PSD import/export, animation, scripting

LOW-SPEC PROFILE (baked defaults for 4 GB RAM / 2-core CPUs)
  memoryHardLimitPercent=35   memorySoftLimitPercent=2
  maxNumberOfThreads=2        maxSwapSize=2048
  undoStackLimit=100
Users can override any key in ~/.config/kritarc (root group, top of
file, no section header). A reference of further low-memory keys is in
/usr/share/creative-studio/LOWMEM-PROFILE.conf.

USAGE
  chmod +x CreativeStudio-Ultimate-Full-x86_64.AppImage
  ./CreativeStudio-Ultimate-Full-x86_64.AppImage [file]
No root installation required; runs offline.
EOF
step "docs added"

step "mksquashfs (zstd-19) + assemble"
rm -f /tmp/new.sqsh
mksquashfs /tmp/sq-final /tmp/new.sqsh -comp zstd -Xcompression-level 19 -b 1M -all-root -noappend -quiet -no-progress 2>>/tmp/mksq-final.log
python3 - <<'PY'
import struct, hashlib, os
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
assert sq[:4] == b"hsqs"
md5 = hashlib.md5(sq).digest()
rt[0xe3900:0xe3910] = md5
open("/out/final.AppImage", "wb").write(bytes(rt) + sq)
os.chmod("/out/final.AppImage", 0o755)
print("FINAL_TOTAL=%d" % len(out) if False else "FINAL_TOTAL=%d" % (rt_size + len(sq)))
PY
step "assembled /out/final.AppImage"
echo "FINAL_DONE" >> $LOG
cat $LOG
EOF