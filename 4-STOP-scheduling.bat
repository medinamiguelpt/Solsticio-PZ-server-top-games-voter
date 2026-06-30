@echo off
cd /d "%~dp0"
if not exist lang.txt (>lang.txt echo es)
set /p LANG=<lang.txt
if "%LANG%"=="en" (goto EN) else (goto ES)

:ES
echo Deteniendo el voto automatico...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0uninstall_task.ps1" %LANG%
pause
goto END

:EN
echo Stopping the automatic voting...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0uninstall_task.ps1" %LANG%
pause
goto END

:END
