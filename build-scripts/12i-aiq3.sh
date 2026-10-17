#!/bin/bash
sed -n "/krita --version under Denverton/,/QEMU_VERSION_EXIT/p" /root/ai-qemu.log | grep -vE "TCG|warning|^$" | head -8
