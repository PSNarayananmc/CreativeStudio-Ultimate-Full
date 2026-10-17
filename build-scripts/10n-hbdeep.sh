#!/bin/bash
echo "=== grep 80300 in install log ==="
grep -c "80300" /root/hbfix-build.log || echo "ZERO mentions"
grep "libharfbuzz.so" /root/hbfix-build.log | head -6
echo "=== actual build tree ==="
find /src/build/hbfix -name "libharfbuzz.so*" 2>/dev/null | head -5
echo "=== now ==="
ls -la --time-style=full-iso /usr/lib/x86_64-linux-gnu/libharfbuzz.so.0* 2>/dev/null
date
