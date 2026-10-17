#!/bin/bash
# chroot-run.sh — run a script inside the focal rootfs as fake-root (user-ns)
# Usage: chroot-run.sh /abs/path/to/script.sh   (script copied to rootfs /tmp)
ROOTFS=/home/z/cs-rootfs
SCRIPT="$1"
[ -f "$SCRIPT" ] || { echo "usage: $0 script.sh"; exit 1; }
BASENAME=$(basename "$SCRIPT")
cp "$SCRIPT" "$ROOTFS/tmp/$BASENAME"
chmod +x "$ROOTFS/tmp/$BASENAME"
exec unshare --user --map-root-user --mount --fork /bin/bash -c "
chroot $ROOTFS /usr/bin/env -i \
  HOME=/root TERM=xterm LANG=C.UTF-8 LC_ALL=C.UTF-8 \
  DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
  LD_PRELOAD=/tmp/fakepriv.so \
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
  EXTERNALS_DOWNLOAD_DIR=/src/externals \
  /bin/bash /tmp/$BASENAME
"
