#!/bin/bash
readelf -d /src/build/hbfix/libharfbuzz.so 2>/dev/null | grep -E "SONAME|NEEDED" | head -4
