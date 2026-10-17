#!/bin/bash
export HOME=/root
export DISPLAY=:77
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
timeout 100 /krita-stage/bin/krita --nosplash --new-image RGBA,U8,64,64 --export-filename /root/cli-test.png > /root/cli-out.log 2>&1 &
KPID=$!
sleep 45
python3 - << "PYEOF"
import sys
from PyQt5.QtWidgets import QApplication
app = QApplication(sys.argv)
pm = app.primaryScreen().grabWindow(0)
pm.save("/root/screen-krita.png")
print("screenshot saved", pm.width(), pm.height())
PYEOF
sleep 2
kill $KPID $XPID 2>/dev/null
ls -la /root/screen-krita.png
