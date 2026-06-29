@echo off
cd /d "%~dp0"
echo Stopping the automatic voting...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0uninstall_task.ps1"
echo.
pause
