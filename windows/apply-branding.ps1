# Applies Creative Studio Ultimate branding to a krita source tree before compilation.
# Mirrors the modifications documented in compliance/SOURCE-CODE-OFFER.txt
# (splash/banner/icon/theme/workspace), minus the Qt 5.12 compat patches which
# are not needed on Windows (KDE's Windows deps ship a newer Qt 5).
#
# Usage: ./windows/apply-branding.ps1 -KritaSrc <path-to-krita-source>
param(
    [Parameter(Mandatory = $true)]
    [string]$KritaSrc
)

$ErrorActionPreference = "Stop"
$branding = Join-Path $PSScriptRoot "branding"

if (-not (Test-Path $KritaSrc)) { throw "krita source not found: $KritaSrc" }

function Copy-Branding([string]$File, [string]$Dest) {
    $target = Join-Path $Dest (Split-Path $File -Leaf)
    $dir = Split-Path $target -Parent
    if (-not (Test-Path $dir)) { throw "expected upstream dir missing: $dir" }
    Copy-Item $File $target -Force
    Write-Host "  patched: $target"
}

Write-Host "== Creative Studio branding overlay -> $KritaSrc =="

# 1. Splash screen + start-page banner (compiled into the binary via qrc)
Copy-Branding "$branding\splash_main.png"            "$KritaSrc\krita\data\splash"
Copy-Branding "$branding\splash_holidays_dummy.png"  "$KritaSrc\krita\data\splash"
Copy-Branding "$branding\banner.svg"                 "$KritaSrc\krita\data\splash"

# 2. Application icon (exe / installer resources)
foreach ($variant in "default", "Next", "Plus", "Beta") {
    $dir = "$KritaSrc\krita\pics\branding\$variant"
    if (Test-Path $dir) {
        Copy-Item "$branding\creative-studio.ico" "$dir\krita.ico" -Force
        Write-Host "  patched: $dir\krita.ico"
    }
}

# 3. Theme + studio workspace (ship as selectable data resources)
Copy-Branding "$branding\CreativeStudioDark.colors"  "$KritaSrc\krita\data\themes"
Copy-Branding "$branding\CreativeStudio.kws"         "$KritaSrc\krita\data\workspaces"

Write-Host "== branding overlay complete =="
Write-Host "note: low-spec config keys are NOT baked into the Windows build"
Write-Host "      (Windows has no /etc/xdg). See branding\LOWMEM-PROFILE.conf"
Write-Host "      and add the keys to %APPDATA%\krita\kritarc if desired."
