#!/bin/bash
# 06a-qt512-source-patches.sh — runs INSIDE chroot (or host): mechanical
# source-level compatibility patches for building Krita 5.2.16 against
# Ubuntu 20.04's Qt 5.12.8. Idempotent.
set -e
K=/src/krita

# Qt::SkipEmptyParts / Qt::KeepEmptyParts -> QString:: equivalents (Qt 5.12 API)
grep -rl "Qt::SkipEmptyParts" $K --include="*.cpp" --include="*.cc" --include="*.h" | while read f; do
  sed -i "s/Qt::SkipEmptyParts/QString::SkipEmptyParts/g" "$f"
  echo "patched SkipEmptyParts: $f"
done
grep -rl "Qt::KeepEmptyParts" $K --include="*.cpp" --include="*.cc" --include="*.h" | while read f; do
  sed -i "s/Qt::KeepEmptyParts/QString::KeepEmptyParts/g" "$f"
  echo "patched KeepEmptyParts: $f"
done

echo "QT512_PATCHES_DONE"

# QImage::convertTo (Qt 5.13+) -> convertToFormat assignment (Qt 5.12 API).
# Only QImage::convertTo takes a QImage::Format argument, so the pattern is precise.
grep -rl "\.convertTo(QImage::Format" $K --include="*.cpp" --include="*.cc" --include="*.h" | while read f; do
  sed -i "s/\([A-Za-z_][A-Za-z0-9_]*\)\.convertTo(QImage::Format/\1 = \1.convertToFormat(QImage::Format/g" "$f"
  echo "patched QImage::convertTo: $f"
done

# QWidget::screen() (Qt 5.14+) -> QWindow::screen()/primaryScreen fallback
if grep -q "slotScreenChanged(mainWindow->screen());" $K/libs/ui/canvas/kis_canvas2.cpp 2>/dev/null; then
  sed -i 's|slotScreenChanged(mainWindow->screen());|slotScreenChanged(mainWindow->topLevelWidget()->window()->windowHandle() \&\& mainWindow->topLevelWidget()->window()->windowHandle()->screen()\n                       ? mainWindow->topLevelWidget()->window()->windowHandle()->screen()\n                       : QGuiApplication::primaryScreen());|' $K/libs/ui/canvas/kis_canvas2.cpp
  echo "patched QWidget::screen(): kis_canvas2.cpp"
fi

# QPainterPath::clear() (Qt 5.13+) -> assignment of fresh path
if grep -q "clipPath.clear();" $K/libs/ui/tool/KisAsyncColorSamplerHelper.cpp 2>/dev/null; then
  sed -i 's|clipPath.clear();|clipPath = QPainterPath();|' $K/libs/ui/tool/KisAsyncColorSamplerHelper.cpp
  echo "patched QPainterPath::clear: KisAsyncColorSamplerHelper.cpp"
fi

# QPainterPath::clear() (Qt 5.13+) -> assignment of fresh path
if grep -q "edge.clear();" $K/libs/ui/widgets/KisColorSamplerPreviewPreview.cpp 2>/dev/null; then
  sed -i 's|edge.clear();|edge = QPainterPath();|' $K/libs/ui/widgets/KisColorSamplerPreviewPreview.cpp
  echo "patched QPainterPath::clear: KisColorSamplerPreviewPreview.cpp"
fi
