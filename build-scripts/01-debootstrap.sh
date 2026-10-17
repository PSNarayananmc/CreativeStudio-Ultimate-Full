#!/bin/bash
# 01-debootstrap.sh — build minimal Ubuntu 20.04 rootfs as unprivileged user
# Run on host. Uses user-namespace fake-root (chroot works, mount/mknod do not).
set -x
LOG=/home/z/my-project/logs/01-debootstrap.log
D=/home/z/downloads/debootstrap-tree
mkdir -p "$D"
cd "$D"
[ -f data.tar.xz ] && ar x /home/z/downloads/debootstrap_1.0.144ubuntu1_all.deb data.tar.xz || true
if [ ! -d usr/share/debootstrap ]; then
  ar t /home/z/downloads/debootstrap_1.0.144ubuntu1_all.deb
  ar x /home/z/downloads/debootstrap_1.0.144ubuntu1_all.deb
  DATAFILE=$(ar t control.deb 2>/dev/null; ls data.tar.* 2>/dev/null | head -1)
  case "$(ls data.tar.* | head -1)" in
    *.zst) tar --zstd -xf data.tar.zst ;;
    *.xz)  tar xJf data.tar.xz ;;
    *.gz)  tar xzf data.tar.gz ;;
    *)     tar xf data.tar ;;
  esac
fi
ls usr/share/debootstrap/ | head -5
unshare --user --map-root-user --mount --fork /bin/bash -c '
  export DEBOOTSTRAP_DIR=/home/z/downloads/debootstrap-tree/usr/share/debootstrap
  export PATH=/home/z/downloads/debootstrap-tree/usr/sbin:$PATH
  debootstrap --variant=minbase --include=ca-certificates,curl,sudo,gpgv focal /home/z/cs-rootfs http://archive.ubuntu.com/ubuntu
' >> "$LOG" 2>&1
echo "DEBOOTSTRAP_EXIT=$?" >> "$LOG"
ls /home/z/cs-rootfs >> "$LOG" 2>&1
