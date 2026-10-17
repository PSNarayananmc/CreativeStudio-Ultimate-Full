#!/bin/bash
# r-08d-phase6-api4.sh — Phase 6 API tests v4: final corrections
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
rm -f /root/p6/v4.results

cat > /root/p6/v4a.py <<'PYEOF'
from krita import *
R = open("/root/p6/v4.results", "a")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
def guard(fn):
    try: fn()
    except Exception as e: res("EXC_" + fn.__name__, False, repr(e)); R.flush()
K = Application
doc = K.createDocument(800, 600, "v4a", "RGBA", "U8", "", 120.0)
def _core():
    n1 = doc.createNode("Base", "paintlayer"); doc.rootNode().addChildNode(n1, None)
    n2 = doc.createNode("Ink", "paintlayer");   doc.rootNode().addChildNode(n2, None)
    n3 = doc.createNode("Grp", "grouplayer");   doc.rootNode().addChildNode(n3, None)
    inner = doc.createNode("Inner", "paintlayer"); n3.addChildNode(inner, None)
    w = 100; px = bytearray()
    for i in range(w * w): px += bytes((200, 30, 30, 255))
    n1.setPixelData(bytes(px), 40, 40, w, w)
    doc.refreshProjection()
    pd = bytes(n1.pixelData(60, 60, 4, 4))
    innames = [c.name() for c in n3.childNodes()]
    names = [c.name() for c in doc.rootNode().childNodes()]
    res("t02_multilayer_paint", pd[0] == 200 and pd[3] == 255 and "Inner" in innames,
        "root=%s grp=%s pxR=%d" % (names, innames, pd[0]))
    base = doc.nodeByName("Base")
    mask = doc.createNode("TMask", "transparencymask")
    base.addChildNode(mask, None)
    fm = doc.createNode("FMask", "filtermask")
    base.addChildNode(fm, None)
    types = [c.type() for c in base.childNodes()]
    res("t04_masks_transparency_and_filter", "transparencymask" in types and "filtermask" in types, str(types))
    # gradient input for filter tests saved for later groups
guard(_core)
R.close()
PYEOF

cat > /root/p6/v4b.py <<'PYEOF'
from krita import *
R = open("/root/p6/v4.results", "a")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
doc = K.createDocument(256, 256, "v4b", "RGBA", "U8", "", 120.0)
node = doc.createNode("P", "paintlayer"); doc.rootNode().addChildNode(node, None)
# NON-uniform gradient input
px = bytearray()
for y in range(128):
    for x in range(128):
        px += bytes((x * 2 % 256, y * 2 % 256, (x + y) % 256, 255))
node.setPixelData(bytes(px), 0, 0, 128, 128)
doc.refreshProjection()
before = bytes(node.pixelData(0, 0, 128, 128))
names = K.filters()
strong = [f for f in names if f.lower() in ("invert",) ] or [f for f in names if "invert" in f.lower()]
target = strong[0] if strong else [f for f in names if "blur" in f.lower()][0]
flt = K.filter(target)
try:
    flt.apply(node, 0, 0, 128, 128)
    doc.waitForDone()
    doc.refreshProjection()
    after = bytes(node.pixelData(0, 0, 128, 128))
    diff = sum(1 for i in range(0, len(after), 64) if after[i] != before[i])
    res("t05_filter_apply", after != before, "filter=%s sampled_diff=%d" % (target, diff))
except Exception as e:
    res("t05_filter_apply", False, repr(e))
R.close()
PYEOF

cat > /root/p6/v4c.py <<'PYEOF'
from krita import *
import os, time
R = open("/root/p6/v4.results", "a")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
# GRAY color management with real profile
try:
    gprof = K.profiles("GRAY", "U8")
    R.write("INTROSPECT gray profiles: %s\n" % gprof[:3]); R.flush()
    g = K.createDocument(32, 32, "grayt", "GRAY", "U8", gprof[0], 120.0) if gprof else None
    res("t07b_gray_doc_real_profile", g is not None, str(gprof[:2]))
    conv = "?"
    if g is not None:
        rprof = K.profiles("RGBA", "U8")[0]
        g.convertColorModelAndDepth("RGBA", "U8", rprof)
        conv = g.colorModel()
    res("t07c_convert_gray_to_rgba", conv == "RGBA", conv)
except Exception as e:
    res("t07b_gray_doc_real_profile", False, repr(e))
# exports
doc = K.createDocument(300, 300, "v4c", "RGBA", "U8", "", 120.0)
nd = doc.createNode("L", "paintlayer"); doc.rootNode().addChildNode(nd, None)
px = bytearray()
for i in range(80*80): px += bytes((20, 180, 90, 255))
nd.setPixelData(bytes(px), 5, 5, 80, 80)
doc.refreshProjection()
ex = {}
for ext in ("png", "jpg", "tiff"):
    p = "/root/p6/v4exp.%s" % ext
    try:
        doc.exportImage(p)
        ex[ext] = os.path.exists(p) and os.path.getsize(p) > 500
    except Exception as e:
        ex[ext] = "EXC %r" % e
res("t09c_export_png_jpg_tiff", ex.get("png") is True and ex.get("jpg") is True and ex.get("tiff") is True, str(ex))
R.close()
PYEOF

for g in v4a v4b v4c; do
  PYTHONPATH=/root/p6 timeout 400 $KR --script $g.py > /root/p6/$g.log 2>&1
  echo "EXIT[$g]=$?"
done
echo "=== V4 RESULTS ==="
cat /root/p6/v4.results 2>/dev/null
kill $XPID 2>/dev/null
pkill -f kritarunner 2>/dev/null
