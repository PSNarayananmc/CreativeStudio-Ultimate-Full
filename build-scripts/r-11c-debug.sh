#!/bin/bash
ls /tmp/opt-root/ 2>&1 | head -3
F=$(find /tmp/opt-root -type f -size +2k | head -2)
echo "FIND_SAMPLE: $F"
T=$(head -c 4 /tmp/opt-root/usr/bin/krita | od -An -tx1 | tr -d ' \n')
echo "MAGIC_TEST: [$T]"
CNT=0
for f in $(find /tmp/opt-root -type f -size +2k); do
  if [ "$(head -c 4 "$f" | od -An -tx1 | tr -d ' \n')" = "7f454c46" ]; then CNT=$((CNT+1)); fi
done
echo "ELF_COUNT=$CNT"
