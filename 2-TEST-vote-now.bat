@echo off
cd /d "%~dp0"
echo Testing one vote now. A Chrome window will open for a few seconds...
echo.
python vote.py
echo.
echo ============================================================
echo  Look above for "Vote CONFIRMED" (success) or "On cooldown"
echo  (you already voted in the last 2 hours - that's fine).
echo  If it worked, double-click "3-SCHEDULE-every-2h.bat".
echo ============================================================
pause
