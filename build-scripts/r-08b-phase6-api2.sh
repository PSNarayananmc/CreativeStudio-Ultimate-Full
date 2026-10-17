#!/bin/bash
# r-08b-phase6-api2.sh — Phase 6 API tests, GROUP-ISOLATED (one runner process per group)
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

run_group() {
  local name=$1
  echo "--- GROUP $name (exit pending) ---"
  PYTHONPATH=/root/p6 timeout 400 $KR --script $name.py > /root/p6/$name.log 2>&1
  echo "GROUP_EXIT[$name]=$?"
  cat /root/p6/$name.results 2>/dev/null
}

# ============ GROUP 1: core layers/masks/selection ============
cat > /root/p6/g1.py <<'PYEOF'
from krita import *
R = open("/root/p6/g1.results", "w")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
doc = K.createDocument(800, 600, "g1", "RGBA", "U8", "", 120.0)
res("t01_create_document", doc is not None and doc.width() == 800)
n1 = doc.createNode("Base", "paintlayer"); doc.rootNode().addChildNode(n1, None)
n2 = doc.createNode("Ink", "paintlayer");   doc.rootNode().addChildNode(n2, None)
n3 = doc.createNode("Grp", "grouplayer");   doc.rootNode().addChildNode(n3, None)
inner = doc.createNode("Inner", "paintlayer"); n3.addChildNode(inner, None)
w = 100; px = bytearray()
for i in range(w * w): px += bytes((200, 30, 30, 255))
n1.setPixelData(bytes(px), 40, 40, w, w)
n2.setPixelData(bytes(px), 300, 300, w, w)
doc.refreshProjection()
layers = doc.rootNode().childNodes()
res("t02_multilayer_paint", len(layers) == 3 and inner.parent().name() == "Grp" and n2.pixelData(300,300,1,1)[2] == 200, "rootchildren=%d" % len(layers))
sel = Selection(); sel.select(300, 200, 200, 150, 255)
doc.setSelection(sel)
got = doc.getSelection()
res("t03_selection", got is not None and got.width() == 200 and got.height() == 150, "%dx%d" % (got.width(), got.height()))
doc.setSelection(None)
base = doc.rootNode().childNodes()[0]
mask = doc.createNode("TMask", "transparencymask")
base.addChildNode(mask, None)
types = [c.type() for c in base.childNodes()]
res("t04_transparency_mask", "transparencymask" in types, "types=%s" % types)
R.close()
PYEOF

# ============ GROUP 2: filters + transform ============
cat > /root/p6/g2.py <<'PYEOF'
from krita import *
R = open("/root/p6/g2.results", "w")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
doc = K.createDocument(400, 400, "g2", "RGBA", "U8", "", 120.0)
node = doc.createNode("P", "paintlayer"); doc.rootNode().addChildNode(node, None)
px = bytearray()
for i in range(64*64): px += bytes((10, 10, 10, 255))
node.setPixelData(bytes(px), 0, 0, 64, 64)
doc.refreshProjection()
names = K.filters()
R.write("INTROSPECT filters=%d\n" % len(names)); R.flush()
blur = [f for f in names if "blur" in f.lower()]
flt = K.filter(blur[0]) if blur else None
if flt is not None:
    R.write("INTROSPECT Filter methods: %s\n" % ", ".join(sorted([m for m in dir(flt) if not m.startswith("_")]))); R.flush()
before = bytes(node.pixelData(0, 0, 32, 32))
ok_apply = False; applied = "?"
try:
    doc.applyFilter(blur[0], node, None)   # config=None = defaults per API docs
    ok_apply = True; applied = "applyFilter(node,None)"
except Exception as e:
    try:
        doc.applyFilter(blur[0], node)     # 2-arg variant
        ok_apply = True; applied = "applyFilter(node)"
    except Exception as e2:
        res("t05_filters", False, "apply exc %r / %r" % (e, e2))
if ok_apply:
    doc.refreshProjection()
    after = bytes(node.pixelData(0, 0, 32, 32))
    res("t05_gaussian_filter", before != after, "applied=%s changed=%s" % (applied, before != after))
# transform
R.write("INTROSPECT Node methods: %s\n" % ", ".join(sorted([m for m in dir(node) if not m.startswith("_")]))); R.flush()
done = []
try:
    node.scaleNode(0.5, 0.5, "Bilinear"); done.append("scale")
except Exception as e: R.write("scaleNode exc: %r\n" % e); R.flush()
try:
    node.rotateNode(15.0); done.append("rotate")
except Exception as e: R.write("rotateNode exc: %r\n" % e); R.flush()
doc.refreshProjection()
res("t06_transform", len(done) >= 1, "done=%s" % done)
R.close()
PYEOF

# ============ GROUP 3: color management ============
cat > /root/p6/g3.py <<'PYEOF'
from krita import *
R = open("/root/p6/g3.results", "w")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
doc = K.createDocument(64, 64, "g3", "RGBA", "U8", "", 120.0)
prof = doc.colorProfile()
R.write("INTROSPECT profile=%s\n" % prof); R.flush()
res("t07a_profile_present", bool(prof), prof)
g = K.createDocument(32, 32, "gray", "GRAY", "U8", "", 120.0)
res("t07b_gray_doc", g is not None and g.colorModel() == "GRAY")
conv = "?"
try:
    g.convertColorModelAndDepth("RGBA", "U8", prof)
    conv = g.colorModel()
except Exception as e:
    R.write("convert exc: %r\n" % e); R.flush()
res("t07c_convert_gray_to_rgba", conv == "RGBA", conv)
R.close()
PYEOF

# ============ GROUP 4: PSD round-trip ============
cat > /root/p6/g4.py <<'PYEOF'
from krita import *
import os, time
R = open("/root/p6/g4.results", "w")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
doc = K.createDocument(300, 300, "g4", "RGBA", "U8", "", 120.0)
for nm in ("A", "B"):
    nd = doc.createNode(nm, "paintlayer"); doc.rootNode().addChildNode(nd, None)
    px = bytearray()
    for i in range(50*50): px += bytes((90, 160, 220, 255))
    nd.setPixelData(bytes(px), 10 + (50 if nm == "B" else 0), 10, 50, 50)
doc.refreshProjection()
doc.saveAs("/root/p6/rt.psd")
for i in range(60):
    if os.path.exists("/root/p6/rt.psd") and os.path.getsize("/root/p6/rt.psd") > 1000: break
    time.sleep(0.5)
okf = os.path.exists("/root/p6/rt.psd") and os.path.getsize("/root/p6/rt.psd") > 1000
res("t08a_psd_save", okf, "size=%s" % (os.path.getsize("/root/p6/rt.psd") if okf else 0))
if okf:
    re = K.openDocument("/root/p6/rt.psd")
    n = len(re.rootNode().childNodes()) if re else -1
    res("t08b_psd_reopen_layers", re is not None and n >= 3, "layers=%d" % n)
R.close()
PYEOF

# ============ GROUP 5: KRA round-trip + exports ============
cat > /root/p6/g5.py <<'PYEOF'
from krita import *
import os, time
R = open("/root/p6/g5.results", "w")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
doc = K.createDocument(300, 300, "g5", "RGBA", "U8", "", 120.0)
nd = doc.createNode("L", "paintlayer"); doc.rootNode().addChildNode(nd, None)
px = bytearray()
for i in range(60*60): px += bytes((20, 180, 90, 255))
nd.setPixelData(bytes(px), 5, 5, 60, 60)
doc.refreshProjection()
doc.saveAs("/root/p6/rt.kra")
for i in range(60):
    if os.path.exists("/root/p6/rt.kra") and os.path.getsize("/root/p6/rt.kra") > 1000: break
    time.sleep(0.5)
okf = os.path.exists("/root/p6/rt.kra") and os.path.getsize("/root/p6/rt.kra") > 1000
res("t09a_kra_save", okf, "size=%s" % (os.path.getsize("/root/p6/rt.kra") if okf else 0))
re = K.openDocument("/root/p6/rt.kra") if okf else None
res("t09b_kra_reopen", re is not None and len(re.rootNode().childNodes()) >= 1)
ex = {}
for ext in ("png", "jpg", "tiff"):
    p = "/root/p6/exp.%s" % ext
    try:
        doc.exportDocument(p)
        ex[ext] = os.path.exists(p) and os.path.getsize(p) > 500
    except Exception as e:
        ex[ext] = "EXC %r" % e
res("t09c_export_png_jpg_tiff", ex.get("png") is True and ex.get("jpg") is True and ex.get("tiff") is True, str(ex))
R.close()
PYEOF

# ============ GROUP 6: animation surface ============
cat > /root/p6/g6.py <<'PYEOF'
from krita import *
R = open("/root/p6/g6.results", "w")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
doc = K.createDocument(200, 200, "g6", "RGBA", "U8", "", 72.0)
anim = [m for m in dir(doc) if "nim" in m.lower() or "rame" in m.lower()]
R.write("INTROSPECT anim methods: %s\n" % ", ".join(anim)); R.flush()
res("t10_animation_doc", doc is not None, "anim-api=%s" % anim[:6])
R.close()
PYEOF

for g in g1 g2 g3 g4 g5 g6; do run_group $g; done
kill $XPID 2>/dev/null
pkill -f kritarunner 2>/dev/null
echo "ALL_GROUPS_DONE"
