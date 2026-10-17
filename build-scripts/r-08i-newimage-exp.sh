#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
EX=/tmp/squashfs-root
rm -f /root/p6/ni.png
timeout 130 $EX/AppRun --nosplash --new-image RGBA,U8,256,256 --export-filename /root/p6/ni.png > /root/p6/ni.log 2>&1
echo "NEWIMAGE_EXP_EXIT=$?"
stat -c "NI_SIZE=%s" /root/p6/ni.png 2>/dev/null || echo "NI_MISSING"
rm -f /root/p6/if.png
timeout 130 $EX/AppRun --nosplash /root/p6/rt.kra --export --export-filename /root/p6/if.png > /root/p6/if.log 2>&1
echo "INPUTFILE_EXP_EXIT=$?"
stat -c "IF_SIZE=%s" /root/p6/if.png 2>/dev/null || echo "IF_MISSING"
kill $XPID 2>/dev/null
pkill -f "usr/bin/krita" 2>/dev/null
