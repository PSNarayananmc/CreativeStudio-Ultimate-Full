# Known Limitations — Creative Studio Ultimate (Full)

Honest, complete list of what this build does NOT do or could not verify, with reasons.

## 1. Verification gaps (features shipped, not independently verified here)
These are upstream Krita 5.2.16 code paths shipped unchanged; the synthetic test environment could not drive them:

1. **Text tool end-to-end** — the tool exists (vector-text stack compiled in), but xdotool/Xvfb automation could not complete a text placement: tool-activation popups intercepted synthetic clicks (`evidence/phase7/p6-text-typed.png`, `p6b-text-typed.png`), and headless SVG-text export rendered black (inconclusive). Manual verification on real hardware is expected to work but was not demonstrated.
2. **Autosave timer + crash-recovery prompt + backup-on-save** — config keys verified to the source level (`AutoSaveInterval` root group, seconds; `KisAutoSaveRecoveryDialog` present; `CreateBackupFile` default true), but the autosave timer never fired inside the fake-`/proc` chroot within a 320 s window and no backup path was exercised (no krita.log entries). The shipped config deliberately leaves the recovery prompt enabled at user level.
3. **Wayland-native** — the bundle ships the xcb platform plugin; Wayland only via XWayland.

## 2. Feature deltas vs the full upstream feature set
1. **HEIF/AVIF image import** — not built (libheif/x265 licensing and focal package availability; documented compromise from the build phase). PNG/JPEG/TIFF/OpenEXR/PSD/ORA all work.
2. **G'Mic and some third-party plugin ecosystems** — not bundled (upstream optional).
3. **Photoshop plugin compatibility (8bf)** — not a Krita feature; out of scope.
4. **Parity claim discipline**: the product preserves Krita's full editing capability set (layers/masks/selections/brushes/filters/color management/PSD/animation/scripting) but is NOT claimed to be a full Photoshop replacement; where behaviors differ (e.g. layer styles, adjustment-layer model), Krita's model applies.

## 3. Packaging limitations
1. **Binary stripping rejected**: symbol-stripping `libKF5Crash.so.5` / `libKF5I18n.so.5` breaks application startup in this build (segfault bisect evidence in `evidence/phase7/`). The shipped image keeps symbols (~7 MB larger than the theoretical stripped size). If a future build re-attempts stripping, those libraries (and any combined-strip configuration) must be regression-tested.
2. **Squashfs compression**: the bundled type-2 runtime supports zlib/zstd only; xz (better ratio) is not an option without replacing the runtime. Final size 132.96 MB; the 30 MB target is not achievable without removing core resources (67 MB of brushes/patterns are intrinsic to the "Full" feature set).
3. **First-launch cold cache**: the first start builds the resource database (~10-20 s on a 2-core machine); subsequent starts are fast (~1 s to window measured natively).
4. **kritarunner standalone invocation** requires `LD_LIBRARY_PATH` (normally set by AppRun); the AppImage exposes `kritarunner` through the bundle env.

## 4. Environmental notes from the test campaign
- The build/test sandbox kills background processes at tool-call boundaries; all long tests are chunked scripts (evidence logs are per-chunk).
- kritarunner exits with SIGSEGV during teardown in this environment (Qt 5.12 static-`/proc` interaction); script results are written before exit, so all API test results are valid. GUI processes are unaffected.
- `doc.exportImage()` hangs in kritarunner context even in batchmode; CLI export (`krita file.kra --export --export-filename out`) is the verified automation path.

## 5. Anything else?
If a limitation above blocks your workflow, the fastest path is usually a config change (see `usr/share/creative-studio/LOWMEM-PROFILE.conf` and PERFORMANCE.md) rather than a rebuild — the engine itself is stock Krita 5.2.16.
