#!/usr/bin/env python3
# Phase 2 asset generator — Creative Studio Ultimate branding
# Renders splash (replaces krita's compiled splash resource), app icon,
# start-page banner SVG. Run inside chroot (PyQt5 + offscreen).
import sys, os
os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
from PyQt5.QtWidgets import QApplication
from PyQt5.QtGui import (QImage, QPainter, QLinearGradient, QColor, QPen, QFont,
                         QRadialGradient, QBrush, QPainterPath, QPolygonF)
from PyQt5.QtCore import Qt, QPointF, QRectF

app = QApplication(sys.argv)

ACCENT = QColor("#4fc3f7")     # premium cyan accent
ACCENT2 = QColor("#7c4dff")    # violet secondary
BG_TOP = QColor("#14161a")
BG_BOT = QColor("#0b0c0f")

# ---------- SPLASH 2048x1152 ----------
W, H = 2048, 1152
img = QImage(W, H, QImage.Format_ARGB32)
img.fill(BG_TOP)
p = QPainter(img)
p.setRenderHint(QPainter.Antialiasing)

g = QLinearGradient(0, 0, 0, H)
g.setColorAt(0.0, BG_TOP)
g.setColorAt(1.0, BG_BOT)
p.fillRect(0, 0, W, H, g)

# subtle radial glow center-left
rg = QRadialGradient(QPointF(W*0.32, H*0.45), 900)
rg.setColorAt(0.0, QColor(79, 195, 247, 36))
rg.setColorAt(1.0, QColor(0, 0, 0, 0))
p.fillRect(0, 0, W, H, QBrush(rg))

# fine grid lines
p.setPen(QPen(QColor(255, 255, 255, 10), 1))
for x in range(0, W, 64):
    p.drawLine(x, 0, x, H)
for y in range(0, H, 64):
    p.drawLine(0, y, W, y)

# wordmark
p.setPen(QPen(QColor(255, 255, 255)))
f = QFont("DejaVu Sans", 168, QFont.Black)
p.setFont(f)
p.drawText(QRectF(0, H*0.34, W, 240), Qt.AlignHCenter | Qt.AlignVCenter, "CREATIVE STUDIO")
# accent underline
p.setPen(QPen(ACCENT, 10))
p.drawLine(W*0.28, H*0.56, W*0.72, H*0.56)
# ULTIMATE badge text
p.setPen(QPen(ACCENT))
f2 = QFont("DejaVu Sans", 64, QFont.DemiBold)
f2.setLetterSpacing(QFont.PercentageSpacing, 180)
p.setFont(f2)
p.drawText(QRectF(0, H*0.58, W, 120), Qt.AlignHCenter | Qt.AlignVCenter, "U L T I M A T E")
# footer
p.setPen(QPen(QColor(150, 158, 170)))
f3 = QFont("DejaVu Sans", 26, QFont.Normal)
p.setFont(f3)
p.drawText(QRectF(0, H*0.86, W, 60), Qt.AlignHCenter, "Professional Creative Suite  —  powered by the Krita 5.2.16 engine")
p.drawText(QRectF(0, H*0.91, W, 50), Qt.AlignHCenter, "GNU GPL v3 — libre software")
p.end()
img.save("/src/krita/krita/data/splash/electrichearts_20240506A_kiki_splash.png")
print("splash written")

# holidays dummy = same art (prevents odd second variant)
img.save("/src/krita/krita/data/splash/splash_holidays_dummy.png")

# ---------- BANNER SVG (start page) ----------
banner = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="220" viewBox="0 0 1200 220">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#14161a"/>
      <stop offset="1" stop-color="#0b0c0f"/>
    </linearGradient>
    <linearGradient id="acc" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#4fc3f7"/>
      <stop offset="1" stop-color="#7c4dff"/>
    </linearGradient>
  </defs>
  <rect width="1200" height="220" fill="url(#bg)"/>
  <rect x="60" y="118" width="1080" height="6" fill="url(#acc)" rx="3"/>
  <text x="600" y="86" font-family="DejaVu Sans" font-size="58" font-weight="bold"
        fill="#ffffff" text-anchor="middle">CREATIVE STUDIO ULTIMATE</text>
  <text x="600" y="170" font-family="DejaVu Sans" font-size="24"
        fill="#9aa2b0" text-anchor="middle">Full edition — powered by the Krita engine</text>
</svg>
'''
open("/src/krita/krita/data/splash/banner.svg", "w").write(banner)
print("banner written")

# ---------- APP ICON: 256px PNG + SVG ----------
S = 256
ic = QImage(S, S, QImage.Format_ARGB32)
ic.fill(Qt.transparent)
p = QPainter(ic)
p.setRenderHint(QPainter.Antialiasing)
# rounded tile
path = QPainterPath()
path.addRoundedRect(QRectF(12, 12, S-24, S-24), 48, 48)
tg = QLinearGradient(12, 12, S-12, S-12)
tg.setColorAt(0.0, QColor("#1b1e24"))
tg.setColorAt(1.0, QColor("#0b0c0f"))
p.fillPath(path, QBrush(tg))
p.setPen(QPen(QBrush(QLinearGradient(0, 0, S, 0)), 6, Qt.SolidLine, Qt.RoundCap))
# accent edge top
p.setBrush(Qt.NoBrush)
p.setPen(QPen(ACCENT, 8))
p.drawLine(60, 40, 196, 40)
# CS glyph
p.setPen(QPen(QColor("#ffffff")))
f4 = QFont("DejaVu Sans", 96, QFont.Black)
p.setFont(f4)
p.drawText(QRectF(0, 30, S, S-40), Qt.AlignHCenter | Qt.AlignVCenter, "CS")
p.setPen(QPen(ACCENT2, 10))
p.drawLine(76, S-52, 180, S-52)
p.end()
ic.save("/root/cs-icon-256.png")
print("icon png written")

icon_svg = '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
  <defs>
    <linearGradient id="tile" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="#1b1e24"/>
      <stop offset="1" stop-color="#0b0c0f"/>
    </linearGradient>
  </defs>
  <rect x="12" y="12" width="232" height="232" rx="48" fill="url(#tile)"/>
  <rect x="60" y="36" width="136" height="8" rx="4" fill="#4fc3f7"/>
  <text x="128" y="152" font-family="DejaVu Sans" font-size="96" font-weight="900"
        fill="#ffffff" text-anchor="middle">CS</text>
  <rect x="76" y="200" width="104" height="10" rx="5" fill="#7c4dff"/>
</svg>
'''
open("/root/cs-icon.svg", "w").write(icon_svg)
print("icon svg written")
print("ASSETS_DONE")
