#!/bin/bash
# r-04-apt-testtools.sh — runs INSIDE chroot: light test/repack toolchain (no build deps)
set -e
export DEBIAN_FRONTEND=noninteractive
echo "=== apt update ==="
apt-get -o Acquire::ForceIPv4=true update 2>&1 | tail -2
echo "=== apt install test tools ==="
apt-get -o Acquire::ForceIPv4=true install -y --no-install-recommends \
  xdotool xvfb xauth \
  python3 python3-pyqt5 python3-pil \
  qemu-user-static \
  squashfs-tools patchelf \
  file xz-utils zstd curl ca-certificates \
  fonts-dejavu-core desktop-file-utils \
  procps psmisc lsof
echo "=== versions ==="
xdotool --version 2>/dev/null | head -1
qemu-x86_64-static --version | head -1
mksquashfs -version 2>/dev/null | head -1
python3 --version
apt-get clean
rm -rf /var/lib/apt/lists/*
echo "TEST_TOOLS_DONE"
