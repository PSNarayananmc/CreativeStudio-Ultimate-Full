# Applies Creative Pic branding to a krita source tree before compilation.
# Mirrors the modifications documented in compliance/SOURCE-CODE-OFFER.txt
# (splash/banner/icon/theme/workspace + display-name patches), minus the
# Qt 5.12 compat patches which are not needed on Windows (KDE's Windows deps
# ship a newer Qt 5).
#
# Usage: ./windows/apply-branding.ps1 -KritaSrc <path-to-krita-source>
param(
    [Parameter(Mandatory = $true)]
    [string]$KritaSrc
)

$ErrorActionPreference = "Stop"
$branding = Join-Path $PSScriptRoot "branding"

if (-not (Test-Path $KritaSrc)) { throw "krita source not found: $KritaSrc" }

function Copy-Branding([string]$File, [string]$Dest, [string]$NewName) {
    if (-not (Test-Path $Dest)) { throw "expected upstream dir missing: $Dest" }
    $leaf = if ($NewName) { $NewName } else { Split-Path $File -Leaf }
    Copy-Item $File (Join-Path $Dest $leaf) -Force
    Write-Host "  patched: $(Join-Path $Dest $leaf)"
}

Write-Host "== Creative Pic branding overlay -> $KritaSrc =="

# 1. Splash screen + start-page banner (compiled into the binary via qrc).
#    NOTE: splash.qrc maps alias "0.png" -> electrichearts_20240506A_kiki_splash.png,
#    and KisSplashScreen::updateSplashImage() hardcodes ":/splash/0.png" — so the
#    wordmark art MUST overwrite that exact file, not be added under a new name.
Copy-Branding "$branding\splash_main.png"           "$KritaSrc\krita\data\splash" "electrichearts_20240506A_kiki_splash.png"
Copy-Branding "$branding\splash_holidays_dummy.png" "$KritaSrc\krita\data\splash"
Copy-Branding "$branding\banner.svg"                "$KritaSrc\krita\data\splash"

# 2. Application icon (exe / installer resources)
foreach ($variant in "default", "Next", "Plus", "Beta") {
    $dir = "$KritaSrc\krita\pics\branding\$variant"
    if (Test-Path $dir) {
        Copy-Item "$branding\creative-pic.ico" "$dir\krita.ico" -Force
        Write-Host "  patched: $dir\krita.ico"
    }
}

# 3. Theme + studio workspace (ship as selectable data resources)
Copy-Branding "$branding\CreativePicDark.colors" "$KritaSrc\krita\data\themes"
Copy-Branding "$branding\CreativePic.kws"        "$KritaSrc\krita\data\workspaces"

# 4. Display name (window title / taskbar / About) — minimal, config IDs stay
#    "krita" so user settings, plugins and file associations keep working.
$appCpp = "$KritaSrc\libs\ui\KisApplication.cpp"
if (-not (Test-Path $appCpp)) { throw "KisApplication.cpp not found" }
(Get-Content $appCpp -Raw) `
    -replace 'setApplicationDisplayName\("Krita"\);', 'setApplicationDisplayName("Creative Pic");' `
    | Set-Content $appCpp -NoNewline
if ((Get-Content $appCpp -Raw) -notmatch 'setApplicationDisplayName\("Creative Pic"\);') {
    throw "display-name patch did not apply"
}
Write-Host "  patched: libs/ui/KisApplication.cpp (applicationDisplayName -> Creative Pic)"

# 4b. About dialog title ("About Krita" -> "About Creative Pic")
$aboutCpp = "$KritaSrc\libs\ui\dialogs\kis_about_application.cpp"
if (Test-Path $aboutCpp) {
    (Get-Content $aboutCpp -Raw) `
        -replace 'i18n\("About Krita"\)', 'i18n("About Creative Pic")' `
        | Set-Content $aboutCpp -NoNewline
    if ((Get-Content $aboutCpp -Raw) -notmatch 'i18n\("About Creative Pic"\)') {
        throw "about-dialog title patch did not apply"
    }
    Write-Host "  patched: libs/ui/dialogs/kis_about_application.cpp (About Creative Pic)"
} else {
    Write-Host "  note: kis_about_application.cpp not present, skipping about title"
}

# 4c. Message-box / dialog window titles: i18nc("@title:window", "Krita")
#     -> "Creative Pic" (display strings only; GPL attribution texts and
#     upstream website links are intentionally preserved).
$titleMatches = 0
Get-ChildItem "$KritaSrc\libs\ui" -Recurse -Filter *.cpp | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($null -ne $content -and $content.Contains('i18nc("@title:window", "Krita")')) {
        $count = ([regex]::Matches($content, [regex]::Escape('i18nc("@title:window", "Krita")'))).Count
        $new = $content.Replace('i18nc("@title:window", "Krita")', 'i18nc("@title:window", "Creative Pic")')
        Set-Content $_.FullName $new -NoNewline
        $titleMatches += $count
    }
}
Write-Host "  patched: $titleMatches dialog title(s) across libs/ui (@title:window Krita -> Creative Pic)"

# 5. NSIS installer product name (installer wizard, Add/Remove Programs)
$nsi = "$KritaSrc\packaging\windows\installer\installer_krita.nsi"
if (Test-Path $nsi) {
    (Get-Content $nsi -Raw) `
        -replace '!define KRITA_PRODUCTNAME "Krita \(x64\)"', '!define KRITA_PRODUCTNAME "Creative Pic (x64)"' `
        -replace '!define KRITA_PRODUCTNAME "Krita \(x86\)"', '!define KRITA_PRODUCTNAME "Creative Pic (x86)"' `
        -replace '!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Krita"', '!define MUI_STARTMENUPAGE_DEFAULTFOLDER "Creative Pic"' `
        | Set-Content $nsi -NoNewline
    Write-Host "  patched: packaging/windows/installer/installer_krita.nsi (product name -> Creative Pic)"
} else {
    Write-Host "  note: installer_krita.nsi not present, skipping NSIS rename"
}

Write-Host "== branding overlay complete =="
Write-Host "note: low-spec config keys are NOT baked into the Windows build"
Write-Host "      (Windows has no /etc/xdg). See branding\kritarc-linux-defaults"
Write-Host "      and add the keys to %APPDATA%\krita\kritarc if desired."
