#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
EX=/tmp/squashfs-root
if [ ! -d $EX ]; then
  rm -f /proc/self/exe; ln -sf /out/CreativeStudio-Ultimate-Full-x86_64.AppImage /proc/self/exe
  cd /tmp && timeout 240 /out/CreativeStudio-Ultimate-Full-x86_64.AppImage --appimage-extract > /dev/null 2>&1
fi
mkdir -p /root/p6
cat > /root/p6/probe.py <<'PY'
print("PYKRITA_LOADED", Application.__name__ if 'Application' in dir() else "NO")
doc = Application.createDocument(64, 64, "probe", "RGBA", "U8", "", 120.0)
print("DOC_CREATED", doc is not None)
print("DOC_WIDTH", doc.width())
Application.closeDocument(doc)
print("PROBE_DONE")
PY
echo "=== try kritarunner -s ==="
timeout 240 $EX/AppRun kritarunner -s /root/p6/probe.py 2>&1 | grep -vE "QStandardPaths" | head -10
echo "TRY1_EXIT=$?"
echo "=== try krita --script ==="
timeout 240 $EX/AppRun krita --nosplash --script /root/p6/probe.py 2>&1 | grep -vE "QStandardPaths" | head -10
echo "TRY2_EXIT=$?"
kill $XPID 2>/dev/null
