#!/bin/bash
export HOME=/root
export DISPLAY=:77
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
Xvfb :77 -screen 0 1920x1080x24 -nolisten tcp > /tmp/xvfb.log 2>&1 &
XPID=$!
EX=/tmp/squashfs-root
sleep 5
cat > /root/text-test.svg <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="800" height="400">
  <rect width="800" height="400" fill="white"/>
  <text x="60" y="200" font-family="DejaVu Sans" font-size="72" fill="black">Creative Studio</text>
</svg>
SVG
timeout 300 $EX/AppRun --nosplash /root/text-test.svg --export --export-filename /root/svgtext.png > /root/svgtext.log 2>&1
echo "SVGTEXT_EXIT=$?"
python3 - <<'PY'
import os
from PIL import Image
if os.path.exists("/root/svgtext.png") and os.path.getsize("/root/svgtext.png") > 500:
    im = Image.open("/root/svgtext.png").convert("L")
    # text region: rows 130-210, cols 60-700 should contain many dark pixels
    dark = sum(1 for x in range(60, 700, 2) for y in range(120, 220, 2) if im.getpixel((x, y)) < 128)
    print("RESULT: svg_text_render = %s dark_px=%d size=%dx%d" % ("PASS" if dark > 150 else "FAIL", dark, im.size[0], im.size[1]))
else:
    print("RESULT: svg_text_render = FAIL (no png)")
PY
kill $XPID 2>/dev/null
pkill -f "usr/bin/krita" 2>/dev/null
