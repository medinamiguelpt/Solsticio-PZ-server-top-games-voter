@echo off
cd /d "%~dp0"
if not exist lang.txt (>lang.txt echo es)
set /p LANG=<lang.txt
if "%LANG%"=="en" (goto EN) else (goto ES)

:ES
echo Activando el voto automatico cada 2 horas...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0setup_task.ps1" %LANG%
pause
goto END

:EN
echo Setting up automatic voting every 2 hours...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0setup_task.ps1" %LANG%
pause
goto END

:END
