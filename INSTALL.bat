@echo off
cd /d "%~dp0"
if not exist lang.txt call :choose
set /p LANG=<lang.txt
call "%~dp0_py.bat"
if not defined PYCMD goto NOPYTHON
if "%LANG%"=="en" (goto EN) else (goto ES)

:choose
choice /c SE /n /m "Elige idioma / Choose language -  [S] Espanol   [E] English: "
if errorlevel 2 (>lang.txt echo en) else (>lang.txt echo es)
goto :eof

:NOPYTHON
echo.
if "%LANG%"=="en" (
  echo ============================================================
  echo  Python is not set up yet, so this can't run.
  echo  1^) Install it from https://www.python.org/downloads/
  echo  2^) On the FIRST installer screen, TICK "Add Python to PATH",
  echo     then click Install Now.
  echo  3^) Then double-click this file again.
  echo  If the Microsoft Store keeps opening, see the README
  echo  ^(section "Something went wrong?"^).
  echo ============================================================
) else (
  echo ============================================================
  echo  Python aun no esta configurado, asi que esto no puede correr.
  echo  1^) Instalalo desde https://www.python.org/downloads/
  echo  2^) En la PRIMERA pantalla del instalador MARCA "Add Python to
  echo     PATH" y pulsa Install Now.
  echo  3^) Vuelve a hacer doble clic en este archivo.
  echo  Si se abre la Microsoft Store una y otra vez, mira el README
  echo  ^(seccion "Algo salio mal?"^).
  echo ============================================================
)
echo.
pause
goto END

:ES
echo ============================================================
echo  Instalando (solo una vez). Tarda alrededor de un minuto.
echo ============================================================
echo.
%PYCMD% -m pip install -r requirements.txt
%PYCMD% patch_nodriver.py
echo.
echo ============================================================
echo  Listo! Ahora abre "username.txt", escribe tu nombre, guarda.
echo  Despues haz doble clic en "SCHEDULE-every-2h.bat".
echo ============================================================
pause
goto END

:EN
echo ============================================================
echo  Installing (one time). Takes about a minute.
echo ============================================================
echo.
%PYCMD% -m pip install -r requirements.txt
%PYCMD% patch_nodriver.py
echo.
echo ============================================================
echo  Done! Now open "username.txt", type your name, save it.
echo  Then double-click "SCHEDULE-every-2h.bat".
echo ============================================================
pause
goto END

:END
