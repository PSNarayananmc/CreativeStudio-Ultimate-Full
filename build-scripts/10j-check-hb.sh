#!/bin/bash
ls -la /usr/lib/x86_64-linux-gnu/libharfbuzz.so* 2>/dev/null
ls /usr/lib/x86_64-linux-gnu/ | grep -E "harfbuzz" 
readlink -f /usr/lib/x86_64-linux-gnu/libharfbuzz.so.0
ls /usr/lib/x86_64-linux-gnu/libharfbuzz*.so.*.* 2>/dev/null
