# Performance & Low-Spec Optimization Report (Phase 4)

Target hardware: Intel Celeron J1800-class (2 cores, in-order Silvermont, SSE4.2 max, no AVX/AVX2), 4 GB RAM, integrated graphics, Ubuntu 20.04.

## Method
Benchmarks run inside the Ubuntu 20.04 chroot with Xvfb and xdotool-driven workloads. Memory sampled host-side at 0.3 s resolution (peak RSS of the whole Krita process tree, `/proc/<pid>/status`). Workload: launch + open a 4000x3000 RGB PNG (48 MP), 60 stroke moves with the freehand brush, Save-As KRA, undo, shutdown, then a separate CLI PNG export. Raw data: `evidence/phase7/bench-stock.csv`, `bench-after.csv`.

## Results — before vs after optimization

| Metric | Stock build | Final build | Delta |
|---|---|---|---|
| Launch → window mapped | 1023 ms | 1020 ms | -0.3% |
| 60 stroke moves (brush engine) | 8.04 s | 8.05 s | +0.2% (noise) |
| Save-As KRA (1.8 MB result) | 8.34 s | 8.34 s | 0 |
| Shutdown (incl. prompt) | 9.05 s | 9.05 s | 0 |
| CLI PNG export | 1.375 s | 1.373 s | 0 |
| Peak RSS — GUI process | 595.9 MB | 586.1 MB | -1.6% |
| Peak RSS — CLI export process | 264.6 MB | 263.5 MB | -0.4% |
| Total peak RSS | 840.3 MB | 829.6 MB | -1.3% |

Interpretation: the recompressed artifact is byte-for-byte the same Krita engine, so per-operation timings are unchanged — as expected. The low-spec value of this phase is in the **memory ceilings** below, which bound worst-case sessions (multi-layer, large canvases) on a 4 GB machine rather than changing short-benchmark numbers.

## Shipped low-spec defaults (baked into the AppImage)

Written to the root group of `usr/etc/xdg/kritarc` (users may override any of these in `~/.config/kritarc`):

| Key | Default (upstream) | Shipped | Rationale |
|---|---|---|---|
| `memoryHardLimitPercent` | 50 | **35** | On a 4 GB box the upstream default allows ~2 GB of tile memory; 35% (~1.4 GB) leaves headroom for X, the desktop and file caches before swap pressure. Never approached by the benchmark (586 MB) — it binds only pathological sessions. |
| `memorySoftLimitPercent` | 2 | 2 | Soft cap before Krita starts swapping tiles: ~80 MB, keeps interactive latency. |
| `maxNumberOfThreads` | idealThreadCount | **2** | Matches the 2-core J1800; avoids thread-pool oversubscription if the runtime reports more cores. |
| `maxSwapSize` | 4096 MiB | **2048 MiB** | Caps on-disk swap growth on small SSDs. |
| `undoStackLimit` | 200 | **100** | Halves the undo-history memory ceiling for long sessions. |

Additional tunable keys are documented in `usr/share/creative-studio/LOWMEM-PROFILE.conf` inside the AppImage (e.g. `useCumulativeUndoRedo=true` for stroke-heavy sessions, `memoryPoolLimitPercent`, single-thread mode).

## CPU instruction compatibility (J1800)

- Build used generic x86-64/SSE2 codegen with Vc/xsimd runtime dispatch — no `-march=native` anywhere.
- Static audit: AVX-family encodings occur only inside xsimd multiarch-dispatched sections, selected at runtime by CPUID (Phase 1 evidence).
- Dynamic audit on the FINAL artifact: `qemu-x86_64-static -cpu Denverton` (SSE4.2, no AVX): `krita --version` exit 0, full GUI launched, real brush strokes painted — no SIGILL (`evidence/phase7/p7-qemu-paint.png`, `p7-qemu2.log`).
- Escape hatch: `disableAVXOptimizations` config key present (set to false; runtime dispatch already guards).

## Size engineering (Phase 7)

| Artifact | Size | Note |
|---|---|---|
| Krita 5.2.16 payload (installed) | 348 MB | before optimization |
| Final payload (pruned) | 316 MB | removed: dev headers (usr/include), non-license docs, .prl, __pycache__; added: GPL compliance docs + lowmem profile |
| Original AppImage (zstd) | 142.07 MB | sha256 901365de… (kept in history) |
| **Final AppImage (zstd-19, 1 MiB blocks)** | **132.96 MB** | sha256 4121b810… |

Why not smaller: Krita's resource set (brushes, patterns, bundles: 67 MB), Qt/KDE runtime (~250 MB) and ICU data (27 MB) are intrinsic to the feature-complete build. Binary stripping (symbol tables) was engineered and tested but **rejected**: stripping `libKF5Crash.so.5` and `libKF5I18n.so.5` provably breaks startup in this build (segfault bisect: `evidence/phase7/p7-bisect.log`, `p7-iso7.log`, `p7-group.log`), and the full-strip configuration remained unstable. Per the project constraint, size is secondary to functionality — the strip was dropped and the -7 MB was traded for guaranteed reliability. The 30 MB ambition is not achievable without removing core features (documented, not silently abandoned).
