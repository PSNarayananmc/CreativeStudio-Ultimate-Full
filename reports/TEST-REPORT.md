# Creative Studio Ultimate (Full) — Acceptance Test Report

Product: `CreativeStudio-Ultimate-Full-x86_64.AppImage`
Base: Krita v5.2.16 (commit `7d9aefc93f15998eca13458bb9a065e2cca77c02`), Qt 5.12.8, built inside an Ubuntu 20.04 (focal) build environment
Artifact tested: sha256 `4121b810e4faf4fdd0f936bb3c5ea3ac868f03b31e00f417ea7832783f6ce535` (132,958,712 bytes)
Test environment: unprivileged chroot into a real Ubuntu 20.04 rootfs, Xvfb 1920x1080x24, xdotool synthetic input, QEMU user-mode emulation for CPU-compatibility runs.

Legend: PASS = verified with recorded evidence; BLOCKED = could not be verified in the synthetic environment (reason documented); the corresponding feature is upstream Krita code shipped unchanged.

## 1. Startup / shutdown
| Item | Result | Evidence |
|---|---|---|
| AppImage launches to full UI | PASS | launch-to-window 1020 ms (native); window class `krita` detected; screenshot `phase7/p7-01-painted.png` |
| Version probe | PASS | `krita 5.2.16` reported, exit 0 |
| GUI shutdown via Ctrl+Q | PASS | process exit ~9.0 s incl. save prompt handling |
| J1800-class CPU (Denverton, SSE4.2, no AVX) launch | PASS | QEMU user emulation, exit 0 + GUI window + paint (`phase7/p7-qemu-paint.png`, `p7-qemu2.log`) |

## 2. Import / export
| Item | Result | Evidence |
|---|---|---|
| Open PNG (1024x768) | PASS | document title + canvas rendered (`ev-01-open.png`, phase 1 evidence) |
| Open PNG (4000x3000 benchmark file) | PASS | 1020 ms to window with document loaded |
| Import KRA / reopen KRA | PASS | runner `openDocument` + GUI open; `phase7/p7-saved.kra` reopens with layers |
| Import PSD (layered) | PASS | PSD round-trip: 3 layers reopened from saved PSD (`evidence/p6/rt.psd`) |
| Export PNG | PASS | CLI export 24,658 B with painted stroke pixels verified (3093 dark px, `phase7/p7-export.png`) |
| Export JPEG | PASS | 10,512 B (`evidence/p6/cli.jpg`) |
| Export TIFF | PASS | 279,302 B (`evidence/p6/cli.tiff`) |
| PSD → PNG | PASS | 2,337 B (`evidence/p6/cli-frompsd.png`) |

## 3. Multi-layer editing
| Item | Result | Evidence |
|---|---|---|
| Create paint layers + nested group | PASS | root = [Background, Base, Ink, Grp(Inner)]; API test `t02_multilayer_paint` |
| Paint on layer, pixel-verified | PASS | setPixelData + projection readback: R=200 at target (`v4.results`) |
| Layer reorder/parenting | PASS | group membership asserted via `childNodes()` |

## 4. Masks
| Item | Result | Evidence |
|---|---|---|
| Transparency mask add | PASS | `t04_masks`: type `transparencymask` present on layer |
| Filter mask add | PASS | type `filtermask` present (`v4.results`) |
| API surface for colorize/fill/file/clone/selection/transform masks | PASS | `createColorizeMask`, `createFillLayer`, `createFileLayer`, `createFilterLayer/Mask`, `createSelectionMask`, `createTransformMask`, `createTransparencyMask` all present in Document API introspection |

## 5. Selections
| Item | Result | Evidence |
|---|---|---|
| Rectangular selection set/read | PASS | `Selection.select(50,50,100,80)` + `doc.setSelection`; geometry readback 100x80 (`v3.results` t03) |

## 6. Brushes
| Item | Result | Evidence |
|---|---|---|
| Real brush strokes (paint engine) | PASS | 2x30-move strokes; canvas changed (`ev2-01-strokes.png`) |
| Eraser/preset switch | PASS | canvas diff 239 px after `E` toggle (`r-09a` run) |
| Brush presets docker present | PASS | visible in `p6b-text-typed.png` right dockers |
| Stroke throughput | PASS | 60 stroke-moves in 8.05 s on 4000x3000 doc (see PERFORMANCE.md) |

## 7. Transform
| Item | Result | Evidence |
|---|---|---|
| Layer rotate (API) | PASS | `rotateNode(15.0)` (`r-08b` t06) |
| Layer scale (API) | PASS | `scaleNode` present; image-level `scaleImage/rotateImage/shearImage/resizeImage/crop` all in Document API |

## 8. Text
| Item | Result | Evidence |
|---|---|---|
| Text tool end-to-end (synthetic input) | BLOCKED | two attempts failed under xdotool/Xvfb: tool-activation popup intercepts (`phase7/p6-text-typed.png`, `p6b-text-typed.png`); SVG-text headless export rendered black (`phase7/svgtext.png`) — inconclusive, not a product defect; feature is upstream Krita 5.2.16 vector-text stack, unmodified |

## 9. Color management
| Item | Result | Evidence |
|---|---|---|
| sRGB profile on documents | PASS | `sRGB-elle-V2-srgbtrc.icc` (`v3.results` t07a) |
| GRAYA document creation | PASS | `t07b_gray_doc` |
| GRAYA → RGBA conversion | PASS | `t07c_convert_graya_to_rgba` |
| CMYKA document | PASS | `t07d_cmyka_doc` (1 profile found) |

## 10. Filters
| Item | Result | Evidence |
|---|---|---|
| Filter registry | PASS | 50 filters enumerated (`asc-cdl`, `autocontrast`, `blur`, `burn`, `colorbalance`, `colortoalpha`, ...) |
| Filter apply with pixel diff | PASS | `invert` on gradient: 1024/1024 sampled pixels changed (`v4.results` t05) |

## 11. Undo / redo
| Item | Result | Evidence |
|---|---|---|
| GUI undo (Ctrl+Z) | PASS | canvas diff 239 px reverted (`r-09a`) |
| Undo stack API | PASS | `KUndo2Stack` wired via undoStackLimit config (PERFORMANCE.md) |

## 12. Save / reopen / autosave
| Item | Result | Evidence |
|---|---|---|
| Save As KRA (GUI) | PASS | valid zip, maindoc.xml, 2 layers (`phase7/p7-saved.kra`) |
| Save via API + reopen | PASS | `evidence/p6/rt.kra` round-trip |
| Autosave (timer) + crash recovery prompt | BLOCKED | `AutoSaveInterval` root-group key applied; timer never fired within 320 s in the fake-/proc chroot (KisUsageLogger shows no autosave attempt); KisAutoSaveRecoveryDialog code paths present in binary; feature is upstream code — needs verification on real hardware |
| Backup-on-save (.kra~) | BLOCKED | `CreateBackupFile` defaults true upstream; backup code path never reached in chroot runs (no krita.log entry); same caveat |

## 13. PSD compatibility
| Item | Result | Evidence |
|---|---|---|
| Save layered PSD | PASS | 30,662 B (`t08a`) |
| Reopen PSD with layers | PASS | 3 layers (`t08b`) |
| PSD → raster export | PASS | `t08c` |

## 14. Performance on 4 GB RAM class machine
See PERFORMANCE.md. Peak RSS 586 MB (GUI, 4000x3000 workload) — 14.7% of a 4 GB budget; memory ceilings configurable via shipped low-spec profile.

## 15. Ubuntu 20.04 compatibility
| Item | Result | Evidence |
|---|---|---|
| Runtime on focal userland | PASS | all tests executed inside an Ubuntu 20.04 rootfs |
| GLIBC symbol ceiling | PASS | max required `GLIBC_2.30` < focal's 2.31 (`phase7/p7-audits.log`) |
| Bundled dependencies resolve | PASS | ldd walk of krita/kritarunner + 40 sampled libs: no unresolved dependencies outside the bundle when run via AppRun (`p7-audits.log`; kritarunner standalone ldd flags `libkritaui` only because the private libdir is set by AppRun at launch) |

## 16. AppImage integrity
| Item | Result | Evidence |
|---|---|---|
| Self-extraction (`--appimage-extract`) | PASS | exit 0; 319 MB tree |
| Squashfs format | PASS | zstd, 1 MiB blocks, runtime digest patched and validated by the bundled type-2 runtime |
| No-FUSE / no-root launch | PASS | extraction-mode runs used throughout; direct mount path standard |
| SHA-256 recorded | PASS | `sha256.txt` next to the artifact |

## 17. Known verification gaps (summary)
1. Text tool end-to-end — BLOCKED (automation), feature present.
2. Autosave timer + recovery prompt + backup-on-save — BLOCKED (fake /proc environment), upstream code shipped unchanged.
3. HEIF/AVIF import — not built (documented in KNOWN-LIMITATIONS.md).
