#!/bin/bash
echo "=== build log tail ==="
tail -6 /root/hbfix-build.log
echo "=== install log check ==="
ls -la /src/build/hbfix/src/libharfbuzz.so* 2>/dev/null | head -4
