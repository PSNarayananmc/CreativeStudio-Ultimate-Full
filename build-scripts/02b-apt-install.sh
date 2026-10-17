#!/bin/bash
# 02b-apt-install.sh — runs INSIDE chroot: full build dependency set
set -e
export DEBIAN_FRONTEND=noninteractive
echo "=== apt update ==="
apt-get update
echo "=== apt install build deps ==="
apt-get install -y --no-install-recommends \
  build-essential cmake ninja-build git pkg-config bison flex curl ca-certificates file \
  python3 python3-dev python3-pip python3-sip-dev python3-pyqt5 \
  shared-mime-info fonts-dejavu-core xvfb xauth \
  qtbase5-dev qtbase5-dev-tools qtdeclarative5-dev qtmultimedia5-dev \
  qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5x11extras5-dev libqt5opengl5-dev \
  qml-module-qtquick2 qml-module-qtquick-controls2 qtquickcontrols2-5-dev \
  extra-cmake-modules \
  libkf5archive-dev libkf5completion-dev libkf5config-dev libkf5configwidgets-dev \
  libkf5coreaddons-dev libkf5crash-dev libkf5guiaddons-dev libkf5i18n-dev \
  libkf5itemmodels-dev libkf5itemviews-dev libkf5widgetsaddons-dev \
  libkf5windowsystem-dev libkf5xmlgui-dev libkf5kio-dev libkf5notifications-dev \
  libkf5iconthemes-dev libkf5kdcraw-dev \
  libboost-dev libeigen3-dev libexiv2-dev libopenexr-dev liblcms2-dev \
  libpng-dev libjpeg8-dev zlib1g-dev libtiff5-dev libgsl-dev libfftw3-dev \
  libpoppler-qt5-dev libcurl4-openssl-dev libopencolorio-dev \
  libx11-dev libxi-dev libxext-dev libxfixes-dev libxrender-dev libxrandr-dev \
  libxxf86vm-dev libxcb1-dev libfreetype-dev libfontconfig1-dev \
  libharfbuzz-dev libfribidi-dev libglib2.0-dev libjson-c-dev \
  libgl1-mesa-dev libgl1-mesa-dri libgl1-mesa-glx \
  squashfs-tools patchelf xz-utils zstd \
  cmake-data
echo "=== cleanup apt caches ==="
apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb
echo "=== versions ==="
cmake --version | head -1
gcc --version | head -1
python3 --version
qmake --version 2>/dev/null || /usr/lib/qt5/bin/qmake --version
echo "APT_INSTALL_DONE"
