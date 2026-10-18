# Windows build — how the .exe is produced (honest engineering notes)

## What this is

A **real Windows build pipeline** for Creative Pic, running on
GitHub-hosted Windows machines (`windows-latest`) via
[`.github/workflows/windows-build.yml`](../.github/workflows/windows-build.yml).
It does **not** cross-compile and does **not** fake anything: the Linux AppImage
and the Windows build are produced independently, each with the toolchain its
platform requires.

## How it works (mirrors KDE's official Krita Windows CI)

1. Download the verified `krita-5.2.16.tar.xz` (SHA-256
   `3bd3bf78…2ed875`, KDE's official tarball), extract and git-init the
   source.
2. Apply the Creative Pic branding overlay
   ([`apply-branding.ps1`](apply-branding.ps1)): splash screen, start-page
   banner, application icon (`.ico`), Creative Pic Dark theme, Creative Pic
   workspace, window/about/dialog titles, NSIS product name — the same
   modifications as the Linux build (see
   `compliance/SOURCE-CODE-OFFER.txt`). The Qt 5.12 compat patches from Linux
   are **not needed here** because KDE's Windows dependency packages ship a
   newer Qt 5.
3. Clone KDE's official CI tooling (`krita-deps-management` branch `krita/5.2`,
   `krita-ci-utilities`, `ci-utilities`).
4. `run-ci-build.py --platform Windows/Qt5/Shared` fetches **prebuilt Windows
   dependency packages** (Qt 5, KF5, exiv2, OpenEXR, libmypaint, KSeExpr, …)
   from KDE's public artifact registry
   [`teams/ci-artifacts/krita-windows`](https://invent.kde.org/teams/ci-artifacts/krita-windows)
   — the exact same packages the official Krita releases are built against —
   then configures and compiles Krita with CMake/Ninja. The compiler is
   **llvm-mingw clang** (pinned 20251118), not MSVC: KDE's current Windows
   deps are clang-built against libc++ and ship GNU-style `.a` import
   libraries that MSVC's linker cannot consume (the same toolchain family
   KDE's own Windows CI uses today). The deps land in the source dir as
   `_install` and the build in `_build` (`KDECI_WORKDIR_PATH` is
   intentionally unset — KDE's own `windows.yml` comments "don't use
   separate workdir since package script will fail!", and run #15 proved
   exactly that failure mode).
5. `build-windows-package.py` (run with `MINGW_BIN_DIR` pointing at the
   llvm-mingw `bin` so its clean-PATH probes for clang++/objdump/objcopy/strip
   resolve, and with the venv's cmake 3.31.6 first on PATH because
   `MakeInstallerNsis.cmake.in` declares `cmake_minimum_required(3.0)` which
   CMake 4.x refuses) produces:
   - `krita-x64-5.2.16.zip` — **portable** package containing `krita.exe`,
     renamed on upload to `CreativePic-x64-5.2.16-portable.zip`
   - `krita-x64-5.2.16-setup.exe` — **NSIS installer**, renamed on upload to
     `CreativePic-x64-5.2.16-setup.exe` (the packaging script downloads
     NSIS 3.05 itself from `files.kde.org` with a pinned SHA-1; a
     by-product unsigned `.msix` is produced by the upstream script and
     discarded)

Both are attached to the `v0.2` release and kept as workflow artifacts.
The installer wizard title, Add/Remove-Programs entry and Start-Menu
folder say **Creative Pic** (patched into `installer_krita.nsi` by
`apply-branding.ps1`); the main window title reports **Creative Pic**
(patched `KisApplication.cpp` display name), the About dialog says
**About Creative Pic**, and error/message-box titles say **Creative Pic**
(patched `i18nc("@title:window", …)` strings — same patch set as the
Linux build's `build-scripts/apply-creative-pic-branding.sh`).

Notes kept honest about the runner environment:

- `ccache` is disabled in the generated `.kde-ci.yml` for this workflow:
  on a fresh GitHub runner a cold cache gives no speedup, and KDE's
  ccache/cl integration is tuned for their own VM images. Build time is
  unaffected on a cold machine.

## Current status & known caveats (kept honest)

- The pipeline reached green on run #16 (after 15 diagnosed iterations —
  the commit history of this file's neighbours records each fix: python
  3.10 pin, cmake 3.31.6 pin, llvm-mingw ABI match, KisHalfTraits
  clang-21 backport, workdir layout). Every run compiles the full krita
  tree from source on a fresh runner; the raw logs (`build-krita.log`,
  `build-installers.log`) are uploaded as artifacts for any future
  diagnosis.
- **Unsigned binaries**: there is no code-signing certificate, so
  Windows SmartScreen shows a warning on first launch of the setup exe
  (choose "More info → Run anyway"). The portable zip has no such prompt.
- The executable keeps its upstream file name `krita.exe` inside the branded
  package (binary-name stability keeps config dirs, plugins and file
  associations compatible; the visible product name is Creative Pic).
- **Low-spec config keys are not pre-baked** on Windows (Windows has no
  `/etc/xdg` equivalent for KConfig). If you run on 4 GB RAM, add these to
  `%APPDATA%\krita\kritarc` (root group, top of file) — reference:
  [`branding/LOWMEM-PROFILE.conf`](branding/LOWMEM-PROFILE.conf):
  ```
  memoryHardLimitPercent=35
  memorySoftLimitPercent=2
  maxNumberOfThreads=2
  maxSwapSize=2048
  undoStackLimit=100
  ```
- Theme/workspace on Windows: select **Settings → Themes → Creative Pic
  Dark** and **Window → Workspace → Creative Pic** (both ship inside the
  build; auto-default comes with the Linux /etc/xdg mechanism only).

## Running it

- **Automatically**: every push touching `windows/**` or this workflow.
- **Manually**: *Actions → windows-build → Run workflow*.

Expected duration: roughly 1.5–3 hours (deps download + compile + package).
