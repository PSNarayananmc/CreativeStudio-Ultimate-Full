#!/bin/bash
# 04-configure-krita.sh — runs INSIDE chroot: CMake configure for Krita 5.2.16
# Design goals:
#  - generic x86-64 baseline (SSE2) -> safe on Intel J1800 (SSE4.2, no AVX). NO -march=native.
#  - -O2 instead of -O3: fits 2 cores / 4 GB RAM build, smaller code
#  - gold linker fallback memory relief; keep GNU ld default, use -O1 ld pass
#  - English-only (no po) to cut disk; document as compromise
set -e
export NINJA_STATUS="[krita %f/%t %es] "
KRITA_SRC=/src/krita
BUILD=/src/build-krita
PREFIX=/krita-stage

cmake -S "$KRITA_SRC" -B "$BUILD" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-include $KRITA_SRC/krita_qt512_compat.h" \
  -DCMAKE_CXX_FLAGS_RELEASE="-O2 -DNDEBUG" \
  -DCMAKE_C_FLAGS_RELEASE="-O2 -DNDEBUG" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBUILD_TESTING=OFF \
  -DBUILD_KRITA_QT_DESIGNER_PLUGINS=OFF \
  -DDISABLE_PO_INSTALLATION=ON \
  -DBUILD_PYTHON_SCRIPTS=ON \
  -DBUILD_PYTHON_EXTENSIONS=ON \
  -DFOUNDATION_BUILD=OFF \
  -DKRITA_ENABLE_PCH=OFF \
  -DENABLE_TESTING=OFF \
  -DEXTERNALS_DOWNLOAD_DIR=/src/externals

echo "CMAKE_CONFIGURE_DONE"
