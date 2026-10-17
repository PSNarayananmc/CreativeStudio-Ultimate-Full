#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
LOG=/root/p7-audits.log
: > $LOG
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 5
EX=/tmp/squashfs-root

echo "=== AUDIT 1: GLIBC symbol ceiling (max GLIBC_ version required) ===" >> $LOG
MAX=""
for f in $(find $EX -type f -size +10k); do
  [ "$(head -c 4 "$f" | od -An -tx1 | tr -d ' \n')" = "7f454c46" ] || continue
  V=$(readelf -V "$f" 2>/dev/null | grep -oE "GLIBC_[0-9.]+" | sort -Vu | tail -1)
  case "$V" in
    GLIBC_2.3[2-9]|GLIBC_2.4[0-9]) echo "HIGH_GLIBC: $f -> $V" >> $LOG;;
  esac
  [ -n "$V" ] && MAX="$MAX $V"
done
echo "MAX_GLIBC_FOUND: $(echo $MAX | tr ' ' '\n' | sort -Vu | tail -1)" >> $LOG

echo "=== AUDIT 2: dependency check (ldd missing) ===" >> $LOG
MISS=0
for f in $EX/usr/bin/krita $EX/usr/bin/kritarunner $(find $EX/usr/lib -maxdepth 1 -name "*.so*" -type f | head -40); do
  OUT=$(ldd "$f" 2>/dev/null | grep "not found")
  if [ -n "$OUT" ]; then echo "MISSING_DEPS: $f: $OUT" >> $LOG; MISS=$((MISS+1)); fi
done
echo "MISSING_DEP_BINARIES=$MISS (of 42 sampled)" >> $LOG

echo "=== AUDIT 3: QEMU Denverton (J1800-class SSE4.2, no AVX) ===" >> $LOG
timeout 400 qemu-x86_64-static -cpu Denverton $EX/usr/bin/krita --version > /root/qemu-v.txt 2>&1
echo "QEMU_VERSION_EXIT=$?" >> $LOG
head -2 /root/qemu-v.txt >> $LOG
kill $XPID 2>/dev/null
echo "AUDITS_DONE" >> $LOG
cat $LOG
