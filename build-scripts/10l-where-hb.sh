#!/bin/bash
find / -name "libharfbuzz.so.0.80300*" 2>/dev/null | head -3
tail -5 /root/hbfix-install.log 2>/dev/null || tail -5 /root/hbfix-build.log 2>/dev/null
grep -m3 "Installing" /root/hbfix-build.log 2>/dev/null | head -3
ls /usr/lib/x86_64-linux-gnu/libharfbuzz*
