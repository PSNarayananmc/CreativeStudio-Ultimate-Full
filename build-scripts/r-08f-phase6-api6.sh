#!/bin/bash
# r-08f-phase6-api6.sh — v6: batchmode exports per-format + setColorSpace conversion + CMYKA
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR /root/p6
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
EX=/tmp/squashfs-root
if [ ! -d $EX ]; then
  rm -f /proc/self/exe; ln -sf /out/CreativeStudio-Ultimate-Full-x86_64.AppImage /proc/self/exe
  cd /tmp && timeout 240 /out/CreativeStudio-Ultimate-Full-x86_64.AppImage --appimage-extract > /dev/null 2>&1
fi
export LD_LIBRARY_PATH="$EX/usr/lib/x86_64-linux-gnu/krita:$EX/usr/lib/x86_64-linux-gnu:$EX/usr/lib"
export QT_PLUGIN_PATH="$EX/usr/plugins:$EX/usr/lib/x86_64-linux-gnu/qt5/plugins"
export QML2_IMPORT_PATH="$EX/usr/lib/x86_64-linux-gnu/qt5/qml:$EX/usr/lib/qml"
export XDG_DATA_DIRS="$EX/usr/share:/usr/share"
export XDG_CONFIG_DIRS="$EX/etc/xdg:/etc/xdg"
KR=$EX/usr/bin/kritarunner
cd /root/p6
rm -f /root/p6/v6.results

# ---- one invocation: conversion + CMYKA ----
cat > /root/p6/v6a.py <<'PYEOF'
from krita import *
R = open("/root/p6/v6.results", "a")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
K.setBatchmode(True)
g = K.createDocument(32, 32, "grayt", "GRAYA", "U8", K.profiles("GRAYA", "U8")[0], 120.0)
res("t07b_gray_doc", g is not None)
conv = "?"
try:
    rprof = K.profiles("RGBA", "U8")[0]
    if hasattr(g, "setColorSpace"):
        g.setColorSpace("RGBA", "U8", rprof)
        conv = g.colorModel()
    elif hasattr(g, "setColorProfile"):
        g.setColorProfile("RGBA", "U8", rprof)
        conv = g.colorModel()
except Exception as e:
    R.write("convert exc %r\n" % e); R.flush()
res("t07c_convert_graya_to_rgba", conv == "RGBA", conv)
cmyk = None
try:
    cps = K.profiles("CMYKA", "U8")
    if cps:
        cmyk = K.createDocument(32, 32, "cmykt", "CMYKA", "U8", cps[0], 120.0)
except Exception as e:
    R.write("cmyk exc %r\n" % e); R.flush()
res("t07d_cmyka_doc", cmyk is not None, "profiles=%d" % len(K.profiles("CMYKA", "U8")) if True else "")
R.close()
PYEOF

# ---- one invocation per export format (isolate hangs) ----
mk_exp() {
cat > /root/p6/v6x.py <<PYEOF
from krita import *
import os, sys
R = open("/root/p6/v6.results", "a")
K = Application
K.setBatchmode(True)
ext = sys.argv[1] if len(sys.argv) > 1 else "png"
doc = K.createDocument(300, 300, "exp", "RGBA", "U8", "", 120.0)
nd = doc.createNode("L", "paintlayer"); doc.rootNode().addChildNode(nd, None)
px = bytearray()
for i in range(80*80): px += bytes((20, 180, 90, 255))
nd.setPixelData(bytes(px), 5, 5, 80, 80)
doc.refreshProjection()
p = "/root/p6/v6exp." + ext
try:
    io = InfoObject()
    doc.exportImage(p, io)
    R.write("RESULT: t09c_export_%s = %s size=%d\n" % (ext, "PASS" if os.path.exists(p) and os.path.getsize(p) > 500 else "FAIL", os.path.getsize(p) if os.path.exists(p) else 0))
except Exception as e:
    R.write("RESULT: t09c_export_%s = FAIL EXC %r\n" % (ext, e))
R.flush(); R.close()
PYEOF
}

for ext in png jpg tiff; do
  mk_exp
  cp /root/p6/v6x.py /root/p6/v6_$ext.py
  PYTHONPATH=/root/p6 timeout 150 $KR --script v6_$ext.py > /root/p6/v6_$ext.log 2>&1
  echo "EXIT[$ext]=$?"
done

PYTHONPATH=/root/p6 timeout 300 $KR --script v6a.py > /root/p6/v6a.log 2>&1
echo "EXIT[v6a]=$?"
echo "=== V6 RESULTS ==="
cat /root/p6/v6.results 2>/dev/null
kill $XPID 2>/dev/null
pkill -f kritarunner 2>/dev/null
