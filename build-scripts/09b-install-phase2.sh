#!/bin/bash
set -e
S=/krita-stage
# 1. theme
cp /root/CreativeStudioDark.colors $S/share/color-schemes/CreativeStudioDark.colors
# 2. icons
cp /root/cs-icon.svg $S/share/icons/hicolor/scalable/apps/creative-studio.svg
cp /root/cs-icon-256.png $S/share/icons/hicolor/256x256/apps/creative-studio.png
# 3. desktop entry (brand-level, alongside org.kde.krita.desktop)
cat > $S/share/applications/creative-studio.desktop << 'DESK'
[Desktop Entry]
Type=Application
Name=Creative Studio Ultimate
GenericName=Digital Painting Studio
Comment=Professional digital painting suite (Full edition, Krita 5.2.16 engine)
Exec=krita %U
Icon=creative-studio
Terminal=false
Categories=Graphics;
MimeType=application/x-kra;application/x-krita;image/png;image/jpeg;image/tiff;image/webp;image/x-xcf;image/x-psd;image/vnd.adobe.photoshop;
X-KDE-NativeExtension=.kra
DESK
echo "PHASE2_STATIC_INSTALL_DONE"
