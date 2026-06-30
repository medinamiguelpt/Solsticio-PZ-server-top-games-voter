@echo off
cd /d "%~dp0"
if not exist lang.txt (>lang.txt echo es)
set /p LANG=<lang.txt
if "%LANG%"=="en" (echo Voting now... a Chrome window will open for a few seconds.) else (echo Votando ahora... se abrira una ventana de Chrome unos segundos.)
echo.
python vote.py
set RC=%errorlevel%
echo.
echo ============================================================
powershell -ExecutionPolicy Bypass -File "%~dp0_result.ps1" %RC% %LANG%
echo ============================================================
echo.
pause
