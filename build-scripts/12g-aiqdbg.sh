#!/bin/bash
grep -B2 -A6 "QEMU_VERSION" /root/ai-qemu.log | head -14
echo "=== gui log ==="
tail -6 /root/aiq-gui.log 2>/dev/null
