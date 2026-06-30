@echo off
cd /d "%~dp0"
if not exist lang.txt (>lang.txt echo es)
set /p LANG=<lang.txt
powershell -ExecutionPolicy Bypass -Command "Disable-ScheduledTask -TaskName 'Solsticio PZ Voter' -ErrorAction SilentlyContinue | Out-Null"
echo.
if "%LANG%"=="en" (echo  Automatic voting PAUSED. Double-click RESUME.bat to turn it back on.) else (echo  Voto automatico PAUSADO. Doble clic en RESUME.bat para reactivarlo.)
echo.
pause
