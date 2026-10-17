#!/bin/bash
export NINJA_STATUS="[splash-rebuild %f/%t %es] "
cd /src/build-krita
touch /src/krita/krita/data/splash/splash.qrc
ninja krita 2>&1 | tail -2
ninja install 2>&1 | tail -2
echo "SPLASH_REBUILD_DONE"
