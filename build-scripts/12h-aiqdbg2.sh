#!/bin/bash
grep -vE "TCG doesn.t support|warning" /root/aiq-gui.log 2>/dev/null | head -12
echo "=== version stderr ==="
sed -n "/krita --version under Denverton/,/QEMU_VERSION_EXIT/p" /root/ai-qemu.log | head -10
