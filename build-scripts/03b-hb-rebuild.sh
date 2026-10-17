#!/bin/bash
set -e
rm -rf /src/build/harfbuzz
cmake -G Ninja -S /src/harfbuzz-8.3.0 -B /src/build/harfbuzz \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -DHB_BUILD_TESTS=OFF -DHB_BUILD_UTILS=OFF -DHB_HAVE_FREETYPE=ON \
  -DHB_HAVE_GLIB=OFF -DHB_HAVE_GOBJECT=OFF -DBUILD_SHARED_LIBS=ON
ninja -C /src/build/harfbuzz -j2 && ninja -C /src/build/harfbuzz install && ldconfig
echo HB_REBUILD_DONE
