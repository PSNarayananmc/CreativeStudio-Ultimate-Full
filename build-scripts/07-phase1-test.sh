#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
export PYTHONPATH=/root/.local/share/krita/py-scripts
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
timeout 300 /krita-stage/bin/kritarunner -s phase1_test > /root/runner-out.log 2>&1
RUNNER_EXIT=$?
echo "RUNNER_EXIT=$RUNNER_EXIT"
kill $XPID 2>/dev/null
echo "=== RESULTS ==="
cat /root/phase1-results.txt 2>/dev/null || echo "NO RESULTS FILE"
echo "=== FILES ==="
ls -la /root/phase1-test.kra /root/phase1-test.png 2>/dev/null
echo "=== RUNNER TAIL ==="
tail -8 /root/runner-out.log
