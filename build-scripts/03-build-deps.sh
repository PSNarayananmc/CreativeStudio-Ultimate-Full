#!/bin/bash
# 03-build-deps.sh — runs INSIDE chroot: build libs focal lacks
# (xsimd 13.1.0, libunibreak 5.1, libwebp 1.3.2, libmypaint 1.6.1, KSeExpr 4.0.4.0)
# Resume-safe: marker files under /src/markers
set -e
mkdir -p /src/markers /src/externals
export DEBIAN_FRONTEND=noninteractive
M=/src/markers

if [ ! -f $M/xsimd ]; then
echo "=== xsimd 13.1.0 (header-only) ==="
cmake -G Ninja -S /src/xsimd-13.1.0 -B /src/build/xsimd \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -DBUILD_TESTING=OFF
ninja -C /src/build/xsimd -j2 && ninja -C /src/build/xsimd install
touch $M/xsimd
fi

if [ ! -f $M/unibreak ]; then
echo "=== libunibreak 5.1 (autotools) ==="
cd /src/libunibreak-5.1
./configure --prefix=/usr --disable-static --enable-shared
make -j2 && make install
ldconfig
touch $M/unibreak
fi

if [ ! -f $M/webp ]; then
echo "=== libwebp 1.3.2 ==="
cmake -G Ninja -S /src/libwebp-1.3.2 -B /src/build/webp \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -DBUILD_SHARED_LIBS=ON -DWEBP_BUILD_EXTRAS=OFF -DWEBP_BUILD_ANIM_UTILS=OFF \
  -DWEBP_BUILD_CWEBP=OFF -DWEBP_BUILD_DWEBP=OFF -DWEBP_BUILD_GIF2WEBP=OFF \
  -DWEBP_BUILD_IMG2WEBP=OFF -DWEBP_BUILD_VWEBP=OFF -DWEBP_BUILD_LIBWEBPMUX=ON
ninja -C /src/build/webp -j2 && ninja -C /src/build/webp install
ldconfig
touch $M/webp
fi

if [ ! -f $M/mypaint ]; then
echo "=== libmypaint 1.6.1 ==="
cd /src/libmypaint-1.6.1
./configure --prefix=/usr --disable-static --disable-introspection
make -j2 && make install
ldconfig
touch $M/mypaint
fi

if [ ! -f $M/kseexpr ]; then
echo "=== KSeExpr 4.0.4.0 ==="
cmake -G Ninja -S /src/kseexpr -B /src/build/kseexpr \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -DBUILD_DOC=OFF -DBUILD_TESTS=OFF -DBUILD_UTILS=OFF
ninja -C /src/build/kseexpr -j2 && ninja -C /src/build/kseexpr install
ldconfig
touch $M/kseexpr
fi

echo "DEPS_BUILD_DONE"

if [ ! -f $M/immer ]; then
echo "=== immer 0.8.1 (header-only) ==="
cmake -G Ninja -S /src/immer-0.8.1 -B /src/build/immer \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -Dimmer_BUILD_TESTS=OFF -Dimmer_BUILD_EXAMPLES=OFF -Dimmer_BUILD_DOCS=OFF
ninja -C /src/build/immer -j2 && ninja -C /src/build/immer install
touch $M/immer
fi

if [ ! -f $M/zug ]; then
echo "=== zug 0.1.2 (header-only) ==="
cmake -G Ninja -S /src/zug-0.1.2 -B /src/build/zug \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -Dzug_BUILD_TESTS=OFF -Dzug_BUILD_EXAMPLES=OFF
ninja -C /src/build/zug -j2 && ninja -C /src/build/zug install
touch $M/zug
fi

if [ ! -f $M/lager ]; then
echo "=== lager 0.1.3 ==="
cmake -G Ninja -S /src/lager-0.1.3 -B /src/build/lager \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -Dlager_BUILD_TESTS=OFF -Dlager_BUILD_EXAMPLES=OFF -Dlager_BUILD_DOCS=OFF
ninja -C /src/build/lager -j2 && ninja -C /src/build/lager install
touch $M/lager
fi
echo "EXTRA_DEPS_DONE"

if [ ! -f $M/freetype ]; then
echo "=== freetype 2.13.3 ==="
cmake -G Ninja -S /src/freetype-2.13.3 -B /src/build/freetype \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -DFT_DISABLE_HARFBUZZ=TRUE -DFT_DISABLE_BROTLI=TRUE -DFT_DISABLE_BZIP2=TRUE \
  -DBUILD_SHARED_LIBS=ON -DFT_DISABLE_ZLIB=FALSE -DFT_DISABLE_PNG=FALSE
ninja -C /src/build/freetype -j2 && ninja -C /src/build/freetype install
ldconfig
touch $M/freetype
fi

if [ ! -f $M/harfbuzz ]; then
echo "=== harfbuzz 8.3.0 ==="
cmake -G Ninja -S /src/harfbuzz-8.3.0 -B /src/build/harfbuzz \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -DHB_BUILD_TESTS=OFF -DHB_BUILD_UTILS=OFF -DHB_HAVE_FREETYPE=OFF \
  -DHB_HAVE_GLIB=OFF -DHB_HAVE_GOBJECT=OFF -DBUILD_SHARED_LIBS=ON
ninja -C /src/build/harfbuzz -j2 && ninja -C /src/build/harfbuzz install
ldconfig
touch $M/harfbuzz
fi
echo "FT_HB_DONE"
