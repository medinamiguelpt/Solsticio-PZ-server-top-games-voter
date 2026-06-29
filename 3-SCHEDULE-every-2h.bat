@echo off
cd /d "%~dp0"
echo Setting up automatic voting every 2 hours...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0setup_task.ps1"
echo.
echo ============================================================
echo  All set! It will now vote automatically every 2 hours.
echo  Keep your PC on and logged in, and keep any VPN OFF.
echo ============================================================
pause
