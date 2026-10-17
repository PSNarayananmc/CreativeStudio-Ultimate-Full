#!/bin/bash
set -e
cat > /appdir/AppRun << 'AR'
#!/bin/bash
HERE=$(dirname "$(readlink -f "${0}")")
export LD_LIBRARY_PATH="$HERE/usr/lib/x86_64-linux-gnu/krita:$HERE/usr/lib/x86_64-linux-gnu:$HERE/usr/lib:${LD_LIBRARY_PATH}"
export QT_PLUGIN_PATH="$HERE/usr/plugins:$HERE/usr/lib/x86_64-linux-gnu/qt5/plugins"
export QML2_IMPORT_PATH="$HERE/usr/lib/x86_64-linux-gnu/qt5/qml:$HERE/usr/lib/qml"
export XDG_DATA_DIRS="$HERE/usr/share:${XDG_DATA_DIRS}:/usr/share"
export XDG_CONFIG_DIRS="$HERE/etc/xdg:${XDG_CONFIG_DIRS}:/etc/xdg"
exec "$HERE/usr/bin/krita" "$@"
AR
chmod +x /appdir/AppRun
rm -f /appdir/usr/bin/qt.conf
cat > /appdir/usr/bin/qt.conf << 'QC'
[Paths]
Plugins=../plugins
Imports=../lib/x86_64-linux-gnu/qt5/qml
Qml2Imports=../lib/x86_64-linux-gnu/qt5/qml
Data=../share
QC
echo "APPDIR_FIXED"
