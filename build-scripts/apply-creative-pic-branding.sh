#!/bin/bash
# apply-creative-pic-branding.sh — Linux source-string patch, mirror of the
# source-patch sections of windows/apply-branding.ps1 so the AppImage and the
# Windows build carry the SAME user-visible branding:
#   1. KisApplication.cpp  : setApplicationDisplayName("Krita" -> "Creative Pic")
#   2. kis_about_application.cpp : i18n("About Krita" -> "About Creative Pic")
#   3. libs/ui/**/*.cpp    : i18nc("@title:window", "Krita" -> "Creative Pic")
# Internal identifiers (appName "krita", MIME types, .kra format, Kis* classes,
# config keys) are intentionally untouched for compatibility; upstream GPL
# attribution texts and website links are preserved.
#
# Usage: apply-creative-pic-branding.sh <path-to-krita-source>
set -euo pipefail

KRITA_SRC="${1:?usage: apply-creative-pic-branding.sh <krita-src-dir>}"
echo "== Creative Pic source-string branding -> $KRITA_SRC =="

# 1. Application display name (drives the window title bar: "<doc> — <name>")
app_cpp="$KRITA_SRC/libs/ui/KisApplication.cpp"
[ -f "$app_cpp" ] || { echo "FATAL: KisApplication.cpp not found"; exit 1; }
sed -i 's/setApplicationDisplayName("Krita");/setApplicationDisplayName("Creative Pic");/' "$app_cpp"
grep -q 'setApplicationDisplayName("Creative Pic");' "$app_cpp" \
    || { echo "FATAL: display-name patch did not apply"; exit 1; }
echo "  patched: libs/ui/KisApplication.cpp (applicationDisplayName -> Creative Pic)"

# 2. About dialog title
about_cpp="$KRITA_SRC/libs/ui/dialogs/kis_about_application.cpp"
if [ -f "$about_cpp" ]; then
    sed -i 's/i18n("About Krita")/i18n("About Creative Pic")/' "$about_cpp"
    grep -q 'i18n("About Creative Pic")' "$about_cpp" \
        || { echo "FATAL: about-dialog title patch did not apply"; exit 1; }
    echo "  patched: libs/ui/dialogs/kis_about_application.cpp (About Creative Pic)"
else
    echo "  note: kis_about_application.cpp not present, skipping about title"
fi

# 3. Message-box / dialog titles across libs/ui
count=$(grep -rl 'i18nc("@title:window", "Krita")' "$KRITA_SRC/libs/ui" --include='*.cpp' 2>/dev/null | wc -l)
if [ "$count" -gt 0 ]; then
    grep -rl 'i18nc("@title:window", "Krita")' "$KRITA_SRC/libs/ui" --include='*.cpp' 2>/dev/null | while read -r f; do
        sed -i 's/i18nc("@title:window", "Krita")/i18nc("@title:window", "Creative Pic")/g' "$f"
    done
    total=$(grep -rc 'i18nc("@title:window", "Creative Pic")' "$KRITA_SRC/libs/ui" --include='*.cpp' 2>/dev/null | awk -F: '{s+=$2} END {print s}')
    echo "  patched: $total dialog title(s) in $count file(s) (@title:window Krita -> Creative Pic)"
else
    echo "  note: no @title:window Krita strings found (already patched?)"
fi

echo "== Creative Pic source-string branding complete =="
