@echo off
cd /d "%~dp0"
if not exist lang.txt (>lang.txt echo es)
set /p LANG=<lang.txt
powershell -ExecutionPolicy Bypass -Command "Enable-ScheduledTask -TaskName 'Solsticio PZ Voter' -ErrorAction SilentlyContinue | Out-Null; $n=(Get-ScheduledTaskInfo -TaskName 'Solsticio PZ Voter' -ErrorAction SilentlyContinue).NextRunTime; if('%LANG%' -eq 'en'){Write-Host ('  Automatic voting RESUMED. Next run: ' + $n)}else{Write-Host ('  Voto automatico REANUDADO. Proxima vez: ' + $n)}"
echo.
pause
