#!/bin/bash
# r-01-fetch-rootfs.sh — rebuild Ubuntu 20.04 (focal) rootfs after sandbox reset
# (previous session used cloud-images tarball; debootstrap hung)
set -x
LOG=/home/z/my-project/logs/r-01-fetch.log
mkdir -p /home/z/my-project/logs
exec >> "$LOG" 2>&1
ROOTFS=/home/z/cs-rootfs
D=/home/z/downloads
mkdir -p "$D" "$ROOTFS"
cd "$D"

if [ ! -d "$ROOTFS/usr/bin" ]; then
  rm -f focal-root.tar.xz
  for url in \
    https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-root.tar.xz \
    https://cloud-images.ubuntu.com/releases/focal/release/focal-server-cloudimg-amd64-root.tar.xz ; do
    echo "=== TRY $url"
    if curl -fL --retry 3 --connect-timeout 20 -o focal-root.tar.xz "$url"; then
      echo "DOWNLOADED: $url"
      break
    fi
  done
  ls -la focal-root.tar.xz || exit 1
  tar -tf focal-root.tar.xz | head -5
  tar -xJf focal-root.tar.xz -C "$ROOTFS"
  rm -f "$D/focal-root.tar.xz"
fi
ls "$ROOTFS" | head -20
[ -x "$ROOTFS/bin/bash" ] && echo "ROOTFS_OK" || { echo "ROOTFS_BROKEN"; exit 1; }
du -sh "$ROOTFS"
