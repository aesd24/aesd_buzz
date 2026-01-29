@echo off
REM Lance le script PowerShell de creation du keystore (depuis cmd ou en double-clic)
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_keystore.ps1"
pause
