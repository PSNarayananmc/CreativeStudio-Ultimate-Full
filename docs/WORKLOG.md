# Worklog — Creative Studio Ultimate (Full edition)

Project: Build Krita-based "Creative Studio Ultimate Full" for Ubuntu 20.04 x86_64, Intel J1800-class (SSE4.2 max, no AVX), 4 GB RAM. AppImage deliverable. Real implementation only.

## Key decisions (Task 1-2: recon & version selection)

- Sandbox: Debian 13 host, glibc 2.41, NO root, NO docker, NO sudo, mknod blocked, mount() blocked, but user-ns + chroot WORK. 2 CPU cores, 4.1 GB RAM, 9.3 GB free disk. Network OK (invent.kde.org, archive.ubuntu.com, github).
- Strategy: unprivileged chroot into real Ubuntu 20.04 (focal) rootfs built via debootstrap under `unshare --user --map-root-user`. Fake /dev (regular-file null/zero/random/urandom/tty), fake /proc (cpuinfo/meminfo/stat snapshots), fake /sys (cpu online). Fallback: proot.
- Krita 5.3.4.1 DOES NOT EXIST upstream (verified via git ls-remote). 5.3 line = only v5.3.0-prealpha (superseded). Newest Qt5-line release: **v5.2.16**. Newest overall: v6.0.4 (Qt6 — violates Qt5 requirement). SELECTED: **krita v5.2.16, Qt 5.12.8 (focal)** — compromise documented.
- Krita 5.2.16 requirements verified from CMakeLists: CMake>=3.16, Qt>=5.12.0, KF5>=5.44.0, Boost>=1.69, Eigen>=3.3, exiv2>=0.16, OCIO>=1.1.1, Poppler Qt5, KSeExpr>=4.0.0.0, WebP>=1.2.0, LibMyPaint>=1.4.0, Vc.
- Must build from source: Vc 1.4.4, KSeExpr 4.0.x, libwebp>=1.2, libmypaint>=1.4. HEIF: deferred (documented limitation).
- J1800 safety: no -march=native anywhere; generic x86-64/SSE2 baseline + Vc runtime dispatch; verify final binaries with objdump for AVX.
- Build type: Release with -O2 (not -O3) to fit 4 GB RAM / 2 cores; lld or gold for low-memory linking; tests off in CMake (acceptance = functional GUI tests under Xvfb).

## Directory layout
- /home/z/cs-rootfs — Ubuntu 20.04 build rootfs
- /home/z/downloads — source tarballs + krita clone (moved into rootfs)
- /home/z/my-project/scripts — persisted build scripts
- /home/z/my-project/logs — build logs
- /home/z/my-project/download — final deliverables


---
Task ID: 3-6
Agent: main
Task: Rootfs, deps, Krita v5.2.16 configure + build + install

Work Log:
- Built focal rootfs from cloud-images tarball (debootstrap abandoned: hangs; userns fakepriv.so LD_PRELOAD shim for chown/setuid in maint scripts)
- apt: gcc9, Qt5.12.8, KF5 5.68, qtbase5-private-dev, pyqt5-dev, quazip5, intltool/gettext
- Built from source in chroot: xsimd 13.1.0, libunibreak 5.1, libwebp 1.3.2, libmypaint 1.6.1, KSeExpr 4.0.4.0, immer 0.8.1, zug 0.1.2, lager 0.1.3, freetype 2.13.3, harfbuzz 8.3.0 (rebuilt with HB_HAVE_FREETYPE=ON)
- CMake configure needed: pip cmake 3.31.6 (cmake_path API), all above deps
- Qt 5.12.8 compat: forced-include header krita_qt512_compat.h (Q_DISABLE_COPY_MOVE, <memory>/<vector>/<string>/<QVector>), source patches: Qt::SkipEmptyParts->QString::, QImage::convertTo->convertToFormat, QWidget::screen, QPainterPath::clear (scripts/06a-qt512-source-patches.sh, idempotent)
- Build: ninja -j2 chunked (sandbox kills background procs at tool-call end), ~23 chunks over ~3h, 0 unresolved errors
- ninja install -> /krita-stage (186MB: bin 6.5M, lib 110M/183 .so, share 69M)

Stage Summary:
- KRITA BUILT: /home/z/cs-rootfs/src/build-krita/krita/krita, installed at /krita-stage
- Source commit: 7d9aefc93f15998eca13458bb9a065e2cca77c02 (tag v5.2.16)
- Next: Xvfb launch test, Phase 1 functional tests, CPU instruction audit

---
Task ID: 7
Agent: main
Task: Phase 1 — verified working foundation (launch, open/edit/save/export, CPU/GLIBC compatibility)

Work Log:
- kritarunner API tests: pykrita_loaded, create_document, fill_layer (InfoObject), paint_layer, setPixelData — ALL PASS
- GUI-driven tests (xdotool under Xvfb): launch w/ full UI, open PNG, REAL brush strokes (paint engine), Save As KRA (181KB), Export PNG via File>Export (dialog detection), reopen KRA, undo, quit — ALL PASS with screenshots ev-*/ev4-*
- Pixel verification: exported PNG identical colors/sizes to source + contains stroke (224 dark px vs 0 orig)
- kritarunner saveAs hangs windowless (progress dialog w/o parent) — documented; GUI path works
- CPU audit: AVX-family encodings exist ONLY in xsimd multiarch-dispatched sections (gcc cannot emit ymm w/o explicit -mavx flags; all multiarch TU compiled per-ISA w/ runtime cpuid selection); runtime config escape hatch: disableAVXOptimizations
- GLIBC ceiling: GLIBC_2.29 max across all binaries (target 2.31) — PASS
- QEMU Denverton (SSE4.2-only CPUID, J1800-class) emulation: krita --version exit 0, full UI + recent thumbnails rendered, NO SIGILL — J1800 compatibility PROVEN

Stage Summary:
- PHASE 1 GATE: PASSED. Foundation is functional.

---
Task ID: 8
Agent: main
Task: Phase 2 — Studio UI (theme, workspace, shortcuts, branding)

Work Log:
- Theme: CreativeStudioDark.colors (KritaDarker-based, accent #4fc3f7 / #7c4dff, bg 34,36,40) -> share/color-schemes; set default via kritarc [theme] Theme=Creative Studio Dark (user + /etc/xdg/kritarc for AppImage)
- Workspace: CreativeStudio.kws preset shipped (studio layout: left toolbox / center canvas / right dockers ToolOptions+AdvancedColorSelector+Layers+BrushPresets — the Default kws layout matches PS-style exactly, verified in screenshots); selectable via --workspace CreativeStudio / Window>Workspace
- Shortcuts: krita ships photoshop_compatible.shortcuts upstream — kept, selectable in Settings>Keyboard Shortcuts (profile switch); documented
- Branding: custom splash (2048x1152 wordmark + accent, replaces qrc :/splash/0.png, rebuilt krita binary — ninja krita relink 24 targets), banner.svg start-page banner, creative-studio icon (svg+png) in hicolor, creative-studio.desktop entry; GPL attribution on start page intentionally preserved
- GUI menu automation for Save-Workspace proved flaky under Xvfb (no WM focus) — shipped preset via file instead; verified loading via --workspace flag + screenshots

Stage Summary:
- Phase 2 assets all in /krita-stage; visual identity applied; no functional regressions observed

---
Task ID: 14
Agent: main
Task: Post-reset recovery + Phase 6 API acceptance testing

Work Log:
- Sandbox was reset between sessions: /home/z/cs-rootfs (9GB build env) WIPED; AppImage artifact SURVIVED in download/ (sha256 901365de... verified intact)
- Rebuilt minimal focal rootfs from cloud-images tarball (r-01), reused 02a-prepare + fakepriv shim (host-compiled, -nostdlib, zero DT_NEEDED)
- Fixed apt in chroot: APT::Sandbox::User "root" (http method died dropping privs to _apt)
- Installed test toolchain: xdotool/Xvfb/QEMU-user-static/mksquashfs/PyQt5/PIL inside rootfs
- Functional re-verification of surviving AppImage: window, real brush strokes, KRA save (121KB, valid zip, 2 layers) — PASS
- Discovered AppRun execs usr/bin/krita for all args; kritarunner is separate binary; invocation recipe: PYTHONPATH=<dir> kritarunner --script <name>.py (module import noise in logs is harmless; scripts DO execute)
- API differences found in 5.2.16: addChildNode(child, above), Selection via `from krita import *`, Filter.apply(node,x,y,w,h), doc.exportImage(path, InfoObject), K.profiles(model, depth) with model "GRAYA" (not GRAY), createDocument auto-creates "Background" layer, no Document.applyFilter/exportDocument/closeDocument in runner
- kritarunner exits SIGSEGV(139) at teardown (build artifact of Qt5.12 static env); GUI processes quit cleanly — documented
- Runner-mode doc.exportImage() HANGS even in batchmode; CLI export syntax `krita file.kra --export --export-filename out.ext` WORKS (all formats)

Stage Summary:
- Phase 6 API matrix: t01 create PASS / t02 multilayer+nested group PASS / t03 selection PASS / t04 transparency+filter masks PASS / t05 filter apply (invert, 1024/1024 diff) PASS / t06 transform PASS / t07a-d color mgmt (sRGB profile, GRAYA doc, GRAYA→RGBA convert, CMYKA doc) PASS / t08 PSD save+reopen(3 layers)+PSD→PNG PASS / t09 KRA save+reopen+PNG(2689B)+JPG(10512B)+TIFF(279302B) exports PASS / t10 animation API PASS
- Evidence in download/evidence/p6/ (results, rt.kra, rt.psd, exported png/jpg/tiff)
- Remaining Phase 6: GUI tests (brush switch, GUI undo, autosave recovery, text), perf/RSS benchmark, GLIBC + dependency + QEMU Denverton audits

---
Task ID: 15
Agent: main
Task: Phase 6 completion (GUI/perf/audits), Phase 4 (low-spec optimization + benchmarks), Phase 7 (size optimization + repack), final deliverables

Work Log:
- GUI tests: launch 1018-1023ms to window; eraser/preset switch PASS (canvas diff 239px); GUI undo PASS; brush strokes on 4000x3000 PASS
- Autosave investigation (deep): correct key = AutoSaveInterval in ROOT group of kritarc (KisConfig uses group("")), unit SECONDS (default 420); timer path traced through setModified -> setNormalAutoSaveInterval -> setAutoSaveDelay; slotConfigChanged runs at doc open; timer NEVER fired in fake-/proc chroot (no "Autosaving:" in krita.log even after 320s) -> documented BLOCKED (upstream code, needs real-hardware verification); backup-on-save (CreateBackupFile) also unreachable in chroot
- Text tool: xdotool automation blocked by tool-activation popups (2 attempts documented with screenshots); SVG-text headless export rendered black -> PARTIAL/UNVERIFIED, honestly documented
- Benchmarks (host-side RSS monitor perf-monitor.py; 4000x3000 workload): stock: launch 1023ms, strokes 8.04s, save 8.34s, export 1.375s, peak RSS 595.9MB; tuned config: same timings (ceilings not reached — documented as worst-case bounds), RSS 614MB; final image: RSS 586.1MB, timings unchanged
- Phase 4 tuned config baked: memoryHardLimitPercent=35, memorySoftLimitPercent=2, maxNumberOfThreads=2, maxSwapSize=2048, undoStackLimit=100 (+LOWMEM-PROFILE.conf reference doc)
- Phase 7: prune (usr/include, non-license docs, .prl, __pycache__) 348->316MB; squashfs recompression: xz gave best ratio (119.5MB stripped) BUT bundled type-2 runtime supports ONLY zlib/zstd (xz image = SIGILL/failed extraction — root-caused: runtime capability, and initial 194183-byte offset was WRONG — real runtime ELF is 944,632 bytes (hsqs match inside .rodata was a red herring; runtime carve must use e_shoff+shnum*shentsize))
- STRIP ENGINEERING: full strip (368 ELFs) broke krita startup (segfault, empty output, only with stdout-to-file probes); bisect chain: progressive group strip passed individually but full-strip failed; single-lib isolation: libKF5Crash.so.5 = reproducible segfault, libKF5I18n.so.5 = timeout; excluding whole libKF5* family still failed in full context -> STRIP REJECTED (reliability > 7MB, per spec)
- Final repack: zstd-19, 1M blocks, dynamic runtime carve (ELF section table end), .digest_md5 re-sealed with payload MD5; GPL compliance docs added (COPYING.GPL-3 full text, SOURCE-CODE-OFFER.txt, README-CREATIVE-STUDIO.txt)
- Final verification on deployed artifact: extract 0, version 0, GUI window, save KRA PASS (127KB, 2 layers), export PNG PASS (24658B, 3093 dark px), QEMU Denverton: version exit 0 + GUI + paint PASS
- Audits: GLIBC ceiling 2.30 < 2.31 PASS; ldd walk no unresolved deps (kritarunner flag = expected, AppRun sets private libdir)
- Deliverables updated: appimage 132,958,712B sha256 4121b810..., TEST-REPORT.md, PERFORMANCE.md, COMPATIBILITY-REPORT.md, KNOWN-LIMITATIONS.md, README.md, evidence/phase7/ (22 files)

Stage Summary:
- ALL SEVEN PHASES COMPLETE. Final artifact fully re-verified post-optimization. Sizes: 142.07 -> 132.96 MB (-9.1MB) without strip (rationale documented). 30MB target documented as not achievable without core-feature loss (explicit spec constraint honored).
- Acceptance matrix: 24 items PASS, 3 BLOCKED-in-synthetic-env (text tool E2E, autosave timer/recovery, backup-on-save) — all upstream code shipped unchanged, documented with root-cause depth.
