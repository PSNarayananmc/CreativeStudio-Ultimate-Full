#!/bin/bash
# r-08e-phase6-api5.sh — v5: profiles introspection + exportImage with InfoObject
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
rm -f /root/p6/v5.results

cat > /root/p6/v5.py <<'PYEOF'
from krita import *
import os
R = open("/root/p6/v5.results", "a")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
try:
    models = K.colorModels()
    R.write("INTROSPECT colorModels: %s\n" % models); R.flush()
    depths = K.colorDepths()
    R.write("INTROSPECT colorDepths: %s\n" % depths); R.flush()
    for m in models:
        ps = K.profiles(m, depths[0])
        R.write("INTROSPECT profiles[%s/%s]: %d -> %s\n" % (m, depths[0], len(ps), list(ps)[:2])); R.flush()
except Exception as e:
    R.write("introspect exc %r\n" % e); R.flush()

# gray doc via whichever model name works
g = None; used = None
for m in ("GRAY", "GRAYA", "GREYA"):
    try:
        ps = K.profiles(m, "U8")
        if not ps: continue
        g = K.createDocument(32, 32, "grayt", m, "U8", ps[0], 120.0)
        used = m; break
    except Exception as e:
        R.write("gray %s exc %r\n" % (m, e)); R.flush()
res("t07b_gray_doc", g is not None, "model=%s" % used)
conv = "?"
if g is not None:
    try:
        rprof = K.profiles("RGBA", "U8")[0]
        g.convertColorModelAndDepth("RGBA", "U8", rprof)
        conv = g.colorModel()
    except Exception as e:
        R.write("convert exc %r\n" % e); R.flush()
res("t07c_convert_gray_to_rgba", conv == "RGBA", conv)

# export with InfoObject
doc = K.createDocument(300, 300, "v5", "RGBA", "U8", "", 120.0)
nd = doc.createNode("L", "paintlayer"); doc.rootNode().addChildNode(nd, None)
px = bytearray()
for i in range(80*80): px += bytes((20, 180, 90, 255))
nd.setPixelData(bytes(px), 5, 5, 80, 80)
doc.refreshProjection()
ex = {}
for ext in ("png", "jpg", "tiff"):
    p = "/root/p6/v5exp.%s" % ext
    try:
        try:
            io = InfoObject()
            doc.exportImage(p, io)
        except Exception:
            doc.exportImage(p, None)
        ex[ext] = os.path.exists(p) and os.path.getsize(p) > 500
    except Exception as e:
        ex[ext] = "EXC %r" % e
res("t09c_export_png_jpg_tiff", ex.get("png") is True and ex.get("jpg") is True and ex.get("tiff") is True, str(ex))
R.close()
PYEOF

PYTHONPATH=/root/p6 timeout 400 $KR --script v5.py > /root/p6/v5.log 2>&1
echo "EXIT=$?"
echo "=== V5 RESULTS ==="
cat /root/p6/v5.results 2>/dev/null
grep -E "INTROSPECT" /root/p6/v5.log 2>/dev/null | head -10
kill $XPID 2>/dev/null
pkill -f kritarunner 2>/dev/null
