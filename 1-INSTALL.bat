@echo off
cd /d "%~dp0"
if not exist lang.txt call :choose
set /p LANG=<lang.txt
if "%LANG%"=="en" (goto EN) else (goto ES)

:choose
choice /c SE /n /m "Elige idioma / Choose language -  [S] Espanol   [E] English: "
if errorlevel 2 (>lang.txt echo en) else (>lang.txt echo es)
goto :eof

:ES
echo ============================================================
echo  Instalando (solo una vez). Tarda alrededor de un minuto.
echo ============================================================
echo.
python -m pip install -r requirements.txt
python patch_nodriver.py
echo.
echo ============================================================
echo  Listo! Ahora abre "username.txt", escribe tu nombre, guarda.
echo  Despues haz doble clic en "2-TEST-vote-now.bat".
echo ============================================================
pause
goto END

:EN
echo ============================================================
echo  Installing (one time). Takes about a minute.
echo ============================================================
echo.
python -m pip install -r requirements.txt
python patch_nodriver.py
echo.
echo ============================================================
echo  Done! Now open "username.txt", type your name, save it.
echo  Then double-click "2-TEST-vote-now.bat".
echo ============================================================
pause
goto END

:END
