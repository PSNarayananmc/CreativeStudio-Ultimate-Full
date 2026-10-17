#!/bin/bash
export NINJA_STATUS="[install %f/%t %es] "
cd /src/build-krita && ninja install 2>&1 | tail -3
echo "INSTALL_EXIT=$?"
ls /krita-stage/bin/ 2>/dev/null | head -5
du -sh /krita-stage 2>/dev/null
