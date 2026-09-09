@echo off
setlocal enabledelayedexpansion
title Return to Mysterious Island - Fix & Play
cd /d "%~dp0"

where powershell.exe >nul 2>nul
if errorlevel 1 (
    echo [ERROR] PowerShell is required to run this fixer.
    pause
    exit /b 1
)

echo ==============================================================
echo    Return to Mysterious Island - Fix and Play
echo    Windows 10/11 DirectDraw fixer + launcher
echo ==============================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0rtmi-fix.ps1"

if errorlevel 1 (
    echo.
    echo Fixer finished with errors. See the messages above.
    pause
)

endlocal