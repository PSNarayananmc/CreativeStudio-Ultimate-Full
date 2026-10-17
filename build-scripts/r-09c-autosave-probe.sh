#!/bin/bash
# r-09c-autosave-probe.sh — introspect autosave config via Krita API
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
cat > /root/p6/asprobe.py <<'PYEOF'
from krita import *
R = open("/root/p6/asprobe.results", "w")
K = Application
for grp in ("", "General", "general", "autosave", "misc", "perf"):
    for key in ("AutoSaveInterval", "autosaveInterval", "autosaveFilePath", "askForAutosaveRecovery", "autoSaveGroup"):
        v = K.readSetting(grp, key, "??unset??")
        if v != "??unset??":
            R.write("READ [%s] %s = %s\n" % (grp or "(null)", key, v))
R.write("--- write probe ---\n")
K.writeSetting("General", "AutoSaveInterval", "1")
R.write("wrote [General] AutoSaveInterval=1\n")
R.write("readback: %s\n" % K.readSetting("General", "AutoSaveInterval", "?"))
R.close()
PYEOF
rm -f /root/.config/kritarc
cd /root/p6
PYTHONPATH=/root/p6 timeout 300 $EX/usr/bin/kritarunner --script asprobe.py > /root/p6/asprobe.log 2>&1
echo "PROBE_EXIT=$?"
cat /root/p6/asprobe.results 2>/dev/null
echo "=== kritarc after write probe ==="
cat /root/.config/kritarc 2>/dev/null
kill $XPID 2>/dev/null
pkill -f kritarunner 2>/dev/null
