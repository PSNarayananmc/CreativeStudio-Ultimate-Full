#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
/krita-stage/bin/krita --nosplash > /root/gui-out.log 2>&1 &
KPID=$!
sleep 30
echo "=== WINDOWS BY NAME ==="
xdotool search --name "Krita" 2>/dev/null | head -5
echo "=== BY CLASS ==="
WID=$(xdotool search --class krita 2>/dev/null | head -1)
echo "WID=$WID"
if [ -n "$WID" ]; then
  xdotool windowactivate $WID 2>/dev/null || true
  sleep 1
  xdotool key --window $WID alt+t
  sleep 2
  python3 -c "from PyQt5.QtWidgets import QApplication; import sys; app=QApplication(sys.argv); app.primaryScreen().grabWindow(0).save('/root/menu-open.png')" 2>/dev/null
fi
kill $KPID $XPID 2>/dev/null
ls -la /root/menu-open.png 2>/dev/null
