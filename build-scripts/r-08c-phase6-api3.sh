#!/bin/bash
# r-08c-phase6-api3.sh — Phase 6 API tests v3: introspection-corrected, fully guarded
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
rm -f /root/p6/v3.results

# ============ v3a: core (layers, selection, masks) ============
cat > /root/p6/v3a.py <<'PYEOF'
from krita import *
R = open("/root/p6/v3.results", "a")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
def guard(fn):
    try: fn()
    except Exception as e: res("EXC_" + fn.__name__, False, repr(e))
K = Application
doc = K.createDocument(800, 600, "v3a", "RGBA", "U8", "", 120.0)
def _core():
    n1 = doc.createNode("Base", "paintlayer"); doc.rootNode().addChildNode(n1, None)
    n2 = doc.createNode("Ink", "paintlayer");   doc.rootNode().addChildNode(n2, None)
    n3 = doc.createNode("Grp", "grouplayer");   doc.rootNode().addChildNode(n3, None)
    inner = doc.createNode("Inner", "paintlayer"); n3.addChildNode(inner, None)
    R.write("INTROSPECT root children: %s\n" % [(c.name(), c.type()) for c in doc.rootNode().childNodes()]); R.flush()
    R.write("INTROSPECT inner parent: %s\n" % (inner.parent().name() if inner.parent() else None)); R.flush()
    w = 100; px = bytearray()
    for i in range(w * w): px += bytes((200, 30, 30, 255))
    n1.setPixelData(bytes(px), 40, 40, w, w)
    doc.refreshProjection()
    pd = bytes(n1.pixelData(60, 60, 4, 4))
    ok = pd[2] == 200 and pd[3] == 255
    names = [c.name() for c in doc.rootNode().childNodes()]
    res("t02_multilayer_paint", ok and set(["Base", "Ink", "Grp"]).issubset(set(names)), "names=%s px=%s" % (names, ok))
    base = [c for c in doc.rootNode().childNodes() if c.name() == "Base"][0]
    mask = doc.createNode("TMask", "transparencymask")
    base.addChildNode(mask, None)
    types = [c.type() for c in base.childNodes()]
    res("t04_transparency_mask", "transparencymask" in types, "types=%s" % types)
    fm = doc.createNode("FMask", "filtermask")
    base.addChildNode(fm, None)
    types2 = [c.type() for c in base.childNodes()]
    res("t04b_filter_mask", "filtermask" in types2, "types=%s" % types2)
guard(_core)
R.close()
PYEOF

# ============ v3b: selection API introspect + fill ============
cat > /root/p6/v3b.py <<'PYEOF'
from krita import *
R = open("/root/p6/v3.results", "a")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
doc = K.createDocument(400, 400, "v3b", "RGBA", "U8", "", 120.0)
R.write("INTROSPECT Document methods: %s\n" % ", ".join(sorted([m for m in dir(doc) if not m.startswith("_")]))); R.flush()
try:
    sel = Selection(); sel.select(50, 50, 100, 80, 255)
    R.write("INTROSPECT Selection made %dx%d\n" % (sel.width(), sel.height())); R.flush()
    setter = None
    for cand in ("setSelection", "selection"):
        if hasattr(doc, cand):
            setter = cand; break
    R.write("INTROSPECT selection setter: %s\n" % setter); R.flush()
    if setter == "setSelection":
        doc.setSelection(sel)
        res("t03_selection_set", True, "setSelection ok")
    else:
        res("t03_selection_set", False, "no setter found")
except Exception as e:
    res("t03_selection_set", False, repr(e))
R.close()
PYEOF

# ============ v3c: filters via Filter.apply ============
cat > /root/p6/v3c.py <<'PYEOF'
from krita import *
R = open("/root/p6/v3.results", "a")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
doc = K.createDocument(400, 400, "v3c", "RGBA", "U8", "", 120.0)
node = doc.createNode("P", "paintlayer"); doc.rootNode().addChildNode(node, None)
px = bytearray()
for i in range(128*128): px += bytes((10, 10, 10, 255))
node.setPixelData(bytes(px), 0, 0, 128, 128)
doc.refreshProjection()
try:
    flt = K.filter("blur")
    applied = []
    for call in ("apply5", "apply4"):
        try:
            if call == "apply5": flt.apply(node, 0, 0, 128, 128)
            else: flt.apply(node, 0, 0, 128, 128)
            applied.append(call); break
        except Exception as e:
            R.write("apply %s exc: %r\n" % (call, e)); R.flush()
    doc.refreshProjection()
    after = bytes(node.pixelData(0, 0, 32, 32))
    res("t05_gaussian_filter", len(applied) > 0 and after != bytes(px[:32*32*4]), "applied=%s changed=%s" % (applied, after != bytes(px[:32*32*4])))
except Exception as e:
    res("t05_gaussian_filter", False, repr(e))
R.close()
PYEOF

# ============ v3d: color mgmt (GRAY with real profile) + exports ============
cat > /root/p6/v3d.py <<'PYEOF'
from krita import *
import os, time
R = open("/root/p6/v3.results", "a")
def res(n, ok, d=""): R.write("RESULT: %s = %s %s\n" % (n, "PASS" if ok else "FAIL", d)); R.flush()
K = Application
gprof = K.profiles("GRAY") if hasattr(K, "profiles") else []
R.write("INTROSPECT gray profiles: %s\n" % gprof); R.flush()
g = None
for p in gprof:
    try:
        g = K.createDocument(32, 32, "grayt", "GRAY", "U8", p, 120.0)
        break
    except Exception as e:
        R.write("gray %s exc: %r\n" % (p, e)); R.flush()
res("t07b_gray_doc_real_profile", g is not None, str(gprof[:2]))
conv = "?"
if g is not None:
    try:
        g.convertColorModelAndDepth("RGBA", "U8", K.profiles("RGBA")[0])
        conv = g.colorModel()
    except Exception as e:
        R.write("convert exc: %r\n" % e); R.flush()
res("t07c_convert_gray_to_rgba", conv == "RGBA", conv)
# exports: introspect doc for export-ish methods
doc = K.createDocument(300, 300, "v3d", "RGBA", "U8", "", 120.0)
nd = doc.createNode("L", "paintlayer"); doc.rootNode().addChildNode(nd, None)
doc.refreshProjection()
exm = [m for m in dir(doc) if "xport" in m]
R.write("INTROSPECT export methods: %s\n" % exm); R.flush()
ex = {}
for ext in ("png", "jpg", "tiff"):
    p = "/root/p6/v3exp.%s" % ext
    try:
        getattr(doc, exm[0])(p)
        ex[ext] = os.path.exists(p) and os.path.getsize(p) > 500
    except Exception as e:
        ex[ext] = "EXC %r" % e
res("t09c_export_png_jpg_tiff", ex.get("png") is True and ex.get("jpg") is True and ex.get("tiff") is True, str(ex))
R.close()
PYEOF

for g in v3a v3b v3c v3d; do
  PYTHONPATH=/root/p6 timeout 400 $KR --script $g.py > /root/p6/$g.log 2>&1
  echo "EXIT[$g]=$?"
done
echo "=== V3 RESULTS ==="
cat /root/p6/v3.results
kill $XPID 2>/dev/null
pkill -f kritarunner 2>/dev/null
