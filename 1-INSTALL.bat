@echo off
cd /d "%~dp0"
echo ============================================================
echo  Installing the voter (one time). This takes about a minute.
echo ============================================================
echo.
python -m pip install -r requirements.txt
python patch_nodriver.py
echo.
echo ============================================================
echo  Done! Next: open "username.txt", type your name, save it.
echo  Then double-click "2-TEST-vote-now.bat".
echo ============================================================
pause
