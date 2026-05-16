@echo off

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Bitte als Administrator starten!
    echo Rechtsklick auf install.bat - Als Administrator ausfuehren
    pause
    exit /b 1
)

if not exist "%~dp0profile_windows.ps1" (
    echo FEHLER: profile_windows.ps1 nicht gefunden!
    echo Beide Dateien muessen im selben Ordner sein.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" "%~dp0profile_windows.ps1"
pause
