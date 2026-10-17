#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 5
EX=/tmp/squashfs-root
echo "=== AppRun --version ==="
timeout 120 $EX/AppRun --version 2>&1 | tail -8
echo "APPRUN_EXIT=$?"
echo "=== bash -x AppRun --version (trace) ==="
timeout 120 bash -x $EX/AppRun --version 2>&1 | tail -12
echo "TRACE_EXIT=$?"
kill $XPID 2>/dev/null
