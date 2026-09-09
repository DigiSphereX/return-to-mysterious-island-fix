param(
    [switch]$Force,        # force re-download and re-install of cnc-ddraw even if ddraw.dll exists
    [switch]$SkipInstall    # never download cnc-ddraw, only patch settings and launch
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$gameDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $gameDir

$cncVersion = 'v7.1.0.0'
$cncUrl     = "https://github.com/FunkyFr3sh/cnc-ddraw/releases/download/$cncVersion/cnc-ddraw.zip"

Write-Host ""
Write-Host "=============================================================="
Write-Host "  Return to Mysterious Island - Fix & Launcher"
Write-Host "  Fixes crash / hang / mouse issues on Windows 10 & 11"
Write-Host "=============================================================="
Write-Host "Game directory : $gameDir"
Write-Host ""

# ---------------------------------------------------------------
# [1/3] Make sure the cnc-ddraw DirectDraw wrapper is installed
# ---------------------------------------------------------------
$ddrawPath = Join-Path $gameDir 'ddraw.dll'
$needInstall = $Force -or $SkipInstall -eq $false -and -not (Test-Path $ddrawPath)

if ($needInstall) {
    if ($SkipInstall) {
        Write-Warning "ddraw.dll is missing but -SkipInstall was used. The game may not start."
    }
    else {
        Write-Host "[1/3] cnc-ddraw wrapper not found - downloading..."
        $zip = Join-Path $env:TEMP 'cnc-ddraw.zip'
        $out = Join-Path $env:TEMP 'cnc-ddraw'

        try {
            if (Test-Path $zip) { Remove-Item $zip -Force -ErrorAction SilentlyContinue }
            if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
                & curl.exe -L --retry 3 --retry-delay 2 -o $zip $cncUrl | Out-Null
            }
            else {
                Invoke-WebRequest -Uri $cncUrl -OutFile $zip -UseBasicParsing
            }
            if (-not (Test-Path $zip) -or (Get-Item $zip).Length -lt 1000000) {
                throw "Downloaded file is missing or too small. Check your internet connection."
            }
            if (Test-Path $out) { Remove-Item $out -Recurse -Force }
            Expand-Archive -Path $zip -DestinationPath $out -Force

            Copy-Item (Join-Path $out '*') $gameDir -Recurse -Force
            Write-Host "      Ok, cnc-ddraw $cncVersion installed to the game folder."
        }
        catch {
            Write-Warning "Automatic download failed: $($_.Exception.Message)"
            Write-Warning "Solution: open https://github.com/FunkyFr3sh/cnc-ddraw/releases ,"
            Write-Warning "download cnc-ddraw.zip and unzip it into the game folder, then run this script again."
            exit 1
        }
    }
}
else {
    Write-Host "[1/3] cnc-ddraw wrapper already present (ddraw.dll exists)."
    if ($Force) { Write-Host "      -Force was used: re-installing over it." }
}

# ---------------------------------------------------------------
# [2/3] Patch config.ini for Windows 10/11 compatibility
# ---------------------------------------------------------------
Write-Host "[2/3] Patching config.ini ..."
$cfgPath = Join-Path $gameDir 'config.ini'
if (Test-Path $cfgPath) {
    Copy-Item $cfgPath ($cfgPath + '.bak') -Force -ErrorAction SilentlyContinue
    $content = Get-Content $cfgPath

    # Fullscreen must be ON so cnc-ddraw controls the presentation (it crashes otherwise on Win11)
    $content = $content -replace '^bFullScreen=\d+', 'bFullScreen=1'
    # Do not force the game to re-centre the cursor every frame (mouse gets stuck)
    $content = $content -replace '^bCenterMouse\s*=\s*\d+', 'bCenterMouse = 0'
    # Point the data path at THIS folder's datas directory
    $content = $content -replace '^PATH=.*', ('PATH=' + (Join-Path $gameDir 'datas'))

    Set-Content $cfgPath $content
    Write-Host "      config.ini patched (backup saved as config.ini.bak)."
}
else {
    Write-Warning "config.ini not found - skipping. Is this the game's root folder?"
}

# ---------------------------------------------------------------
# [3/3] Launch the game
# ---------------------------------------------------------------
Write-Host "[3/3] Launching game ..."
$exeName = if (Test-Path (Join-Path $gameDir 'RtMI.exe')) { 'RtMI.exe' } else { 'Game.exe' }
Start-Process -FilePath (Join-Path $gameDir $exeName) -WorkingDirectory $gameDir
Write-Host "      Started $exeName"
Write-Host ""
Write-Host "NOTE: If the game still misbehaves, open 'cnc-ddraw config.exe'"
Write-Host "in the game folder to tweak rendering, scaling and mouse options."
Write-Host ""