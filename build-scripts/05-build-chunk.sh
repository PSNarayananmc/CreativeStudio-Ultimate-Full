#!/bin/bash
export NINJA_STATUS="[%f/%t %es] "
cd /src/build-krita
ninja -j2 2>&1 | tee /tmp/ninja-latest.log | tail -6
