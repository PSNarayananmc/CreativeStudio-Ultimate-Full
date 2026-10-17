#!/bin/bash
export HOME=/root
export DISPLAY=:77
export PYTHONPATH=/root/.local/share/krita/py-scripts
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
sleep 3
rm -f /root/save-test.log /root/save-test.kra
timeout 120 /krita-stage/bin/kritarunner -s save_test > /root/runner-out.log 2>&1
echo "RUNNER_EXIT=$?"
kill $XPID 2>/dev/null
cat /root/save-test.log 2>/dev/null || echo "no log"
