@echo off
title Hardware Scan - Build Windows Installer
echo ===================================================
echo   Building Hardware Scan Windows Installer (.msi)
echo ===================================================
cd /d "%~dp0"
call gradlew.bat packageMsi
if %ERRORLEVEL% equ 0 (
    echo.
    echo ===================================================
    echo   SUCCESS! Installer generated:
    echo   %~dp0build\compose\binaries\main\msi\HardwareScan-1.0.0.msi
    echo ===================================================
    explorer "%~dp0build\compose\binaries\main\msi"
) else (
    echo [ERROR] Build failed!
)
pause