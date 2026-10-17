#!/bin/bash
echo "=== doc dirs ==="
ls /tmp/sq-orig/usr/share/doc/ | grep -iE "krita|calligra" 
echo "=== krita doc contents ==="
ls /tmp/sq-orig/usr/share/doc/krita/ 2>/dev/null
echo "=== COPYING anywhere ==="
find /tmp/sq-orig -iname "*COPYING*" 2>/dev/null | head -6
echo "=== LICENSE anywhere ==="
find /tmp/sq-orig -iname "LICENSE*" 2>/dev/null | head -6
echo "=== krita share license dirs ==="
ls /tmp/sq-orig/usr/share/krita/ | head -20
