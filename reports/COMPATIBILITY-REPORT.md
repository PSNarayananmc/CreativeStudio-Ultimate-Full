# Compatibility & Dependency Report

## Build provenance
- Application: Creative Studio Ultimate (Full edition) — Krita 5.2.16 engine
- Source: Krita tag `v5.2.16`, commit `7d9aefc93f15998eca13458bb9a065e2cca77c02`
- Toolchain: gcc 9.4 (focal), CMake 3.31.6, Qt 5.12.8 (focal), KF5 5.68 (focal)
- Build type: Release, -O2, generic x86-64/SSE2 baseline (no -march=native)
- Build environment: unprivileged chroot into Ubuntu 20.04 (focal) rootfs

## Runtime requirements of the AppImage
| Requirement | Value |
|---|---|
| Architecture | x86_64 |
| GLIBC (host) | >= 2.30 (max symbol version found in bundle: GLIBC_2.30; target Ubuntu 20.04 ships 2.31 — PASS) |
| Kernel | standard Linux 5.x features only; no FUSE required (extraction mode works everywhere; mount mode optional) |
| Display | X11 (XWayland compatible) |
| RAM | runs in 4 GB (peak 586 MB GUI on 48 MP test workload; ceilings configurable) |
| Disk | ~330 MB extracted + document working space (swap cap 2 GB default) |
| Root/installation | not required; runs from $HOME or any readable path |

## Bundled dependency inventory (main groups)
All libraries below are inside the AppImage (`usr/lib`), so the host needs none of them:

- **Krita engine**: libkritaui, libkritaimage, libkritacolor, libkritacommand, libkritabasicflakes, libkritacolord, libkritaexifcommon + 60+ resource/plugins (~120 MB)
- **Qt 5.12** (focal build): Core, Gui, Widgets, Svg, X11Extras, Multimedia, Network, PrintSupport, DBus, OpenGL + plugins (platforms/xcb, imageformats, sqldrivers, xcbglintegrations)
- **KDE Frameworks 5.68**: Archive, Completion, Config, ConfigGui, CoreAddons, Crash, GuiAddons, I18n, ItemViews, KDcraw, Notifications, WidgetsAddons, WindowSystem, XmlGui
- **Image/graphics**: libpng, libjpeg-turbo, libtiff, zlib, OpenEXR 2.3 (Half/Iex/IlmImf/IlmThread), liblcms2, OpenColorIO, exiv2, libraw (via KDcraw), poppler-qt5 (PDF import), quazip
- **Text**: freetype 2.13, harfbuzz 8.3 (rebuilt with freetype integration), fribidi, fontconfig, libunibreak
- **Color/brush engines**: libmypaint 1.6.1, KSeExpr 4.0.4, immer/zug/lager, xsimd 13.1 (runtime-dispatched), Vc
- **Misc**: ICU data (66), boost (header-used), curl, libwebp 1.3.2
- **Python scripting**: Python 3.8 + PyQt5 + krita-python-libs (PyKrita scripting)

Per-package copyright notices preserved under `usr/share/doc/`; the full GPL-3 text and a written source offer ship in `usr/share/doc/creative-studio/`.

## Platform compatibility evidence
| Platform check | Result |
|---|---|
| Ubuntu 20.04 (focal) userland | PASS — the entire acceptance suite ran inside a focal rootfs |
| GLIBC ceiling | PASS — GLIBC_2.30 max vs 2.31 available |
| J1800-class CPU (Denverton model, SSE4.2/no AVX via QEMU) | PASS — version probe, GUI launch, real painting (`evidence/phase7/p7-qemu-paint.png`) |
| Headless/CI (Xvfb) | PASS — all GUI tests |
| AppImage runtime | type 2, static-pie, self-extracting; squashfs zstd/1MiB; embedded MD5 digest re-sealed after repack |

## Security notes on bundled dependencies
- Bundle contains only the focal-security patched versions available at build time (Qt 5.12.8+security, KF5 5.68, zlib, libpng, libjpeg-turbo, libtiff, OpenEXR 2.3, poppler, exiv2, curl).
- Third-party components rebuilt from source to exceed focal versions where CVEs demanded: libwebp 1.3.2, freetype 2.13.3, harfbuzz 8.3.0.
- No network-facing service is opened by the application; telemetry/news disabled (`showNews=false`).
- AppImage integrity: SHA-256 published; runtime MD5 digest sealed over the payload.

## Known deviations from upstream Krita
1. Qt 5.12.8 compatibility shim (forced-include `krita_qt512_compat.h` + 4 source patches) — engine code unchanged, documented in SOURCE-CODE-OFFER.txt.
2. Branding: splash, banner, icon, desktop entry, color scheme, workspace preset.
3. Default config: low-spec profile keys + news disabled.
4. HEIF/AVIF import not built (codec licensing + focal availability) — see KNOWN-LIMITATIONS.md.
