@echo off
cd /d "%~dp0"
if not exist lang.txt (>lang.txt echo es)
set /p LANG=<lang.txt
call "%~dp0_py.bat"
if not defined PYCMD (
  if "%LANG%"=="en" (echo Python not found. Run 1-INSTALL.bat first.) else (echo No se encontro Python. Ejecuta 1-INSTALL.bat primero.)
  echo.
  pause
  goto :eof
)
if "%LANG%"=="en" (echo Voting now... a Chrome window will open for a few seconds.) else (echo Votando ahora... se abrira una ventana de Chrome unos segundos.)
echo.
%PYCMD% vote.py
set RC=%errorlevel%
echo.
echo ============================================================
powershell -ExecutionPolicy Bypass -File "%~dp0_result.ps1" %RC% %LANG%
echo ============================================================
echo.
pause
