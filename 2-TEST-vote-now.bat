@echo off
cd /d "%~dp0"
if not exist lang.txt (>lang.txt echo es)
set /p LANG=<lang.txt
if "%LANG%"=="en" (goto EN) else (goto ES)

:ES
echo Probando un voto ahora. Se abrira una ventana de Chrome unos segundos...
echo.
python vote.py
set RC=%errorlevel%
echo.
if "%RC%"=="0" echo  RESULTADO: Voto CONFIRMADO!  Ya puedes activar el automatico: 3-SCHEDULE-every-2h.bat
if "%RC%"=="1" echo  RESULTADO: En enfriamiento (ya votaste hace menos de 2h). Es normal, intenta mas tarde.
if "%RC%"=="2" echo  RESULTADO: No paso la verificacion. Apaga la VPN e intenta de nuevo mas tarde.
if "%RC%"=="3" echo  RESULTADO: Falta configurar. Abre "username.txt" y escribe tu nombre.
pause
goto END

:EN
echo Testing one vote now. A Chrome window will open for a few seconds...
echo.
python vote.py
set RC=%errorlevel%
echo.
if "%RC%"=="0" echo  RESULT: Vote CONFIRMED!  You can now turn on auto: 3-SCHEDULE-every-2h.bat
if "%RC%"=="1" echo  RESULT: On cooldown (you voted within the last 2h). Normal - try later.
if "%RC%"=="2" echo  RESULT: Did not pass the check. Turn the VPN off and try again later.
if "%RC%"=="3" echo  RESULT: Not configured. Open "username.txt" and type your name.
pause
goto END

:END
