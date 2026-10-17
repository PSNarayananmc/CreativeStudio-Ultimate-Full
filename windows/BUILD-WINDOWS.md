# Windows build — how the .exe is produced (honest engineering notes)

## What this is

A **real Windows build pipeline** for Creative Pic, running on
GitHub-hosted Windows machines (`windows-latest`) via
[`.github/workflows/windows-build.yml`](../.github/workflows/windows-build.yml).
It does **not** cross-compile and does **not** fake anything: the Linux AppImage
and the Windows build are produced independently, each with the toolchain its
platform requires.

## How it works (mirrors KDE's official Krita Windows CI)

1. Download `krita-5.2.16.tar.xz` from `download.kde.org`, **verify SHA-256**
   (`3bd3bf78…2ed875`), extract and git-init the source.
2. Apply the Creative Studio branding overlay
   ([`apply-branding.ps1`](apply-branding.ps1)): splash screen, start-page
   banner, application icon (`.ico`), Creative Studio Dark theme, Creative
   Studio workspace — the same modifications as the Linux build (see
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
   then configures and compiles Krita with CMake/Ninja under MSVC.
5. `build-windows-package.py` produces:
   - `krita-x64-5.2.16.zip` — **portable** package containing `krita.exe`,
     renamed on upload to `CreativePic-x64-5.2.16-portable.zip`
   - `krita-x64-5.2.16-setup.exe` — **NSIS installer**, renamed on upload to
     `CreativePic-x64-5.2.16-setup.exe` (needs `nsis` via choco; built
     best-effort)

Both are attached to the `v0.2` release and kept as workflow artifacts.
The installer wizard title, Add/Remove-Programs entry and Start-Menu
folder say **Creative Pic** (patched into `installer_krita.nsi` by
`apply-branding.ps1`); the main window title reports **Creative Pic**
(patched `KisApplication.cpp` display name).

## Current status & known caveats (kept honest)

- The first pipeline run is an experiment: on any failure, the raw logs
  (`build-krita.log`, `build-installers.log`) are uploaded as artifacts so
  each iteration can be diagnosed and fixed — that is the normal way this
  pipeline reaches green.
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
