@echo off
cd /d "%~dp0"
if not exist lang.txt (>lang.txt echo es)
set /p LANG=<lang.txt
powershell -ExecutionPolicy Bypass -Command "$t=Get-ScheduledTask -TaskName 'Solsticio PZ Voter' -ErrorAction SilentlyContinue; if(-not $t){ if('%LANG%' -eq 'en'){Write-Host 'Not scheduled yet. Run SCHEDULE-every-2h.bat first.'}else{Write-Host 'Aun no esta programado. Ejecuta SCHEDULE-every-2h.bat primero.'}; exit }; $i=Get-ScheduledTaskInfo -TaskName 'Solsticio PZ Voter'; Write-Host ('Estado/State : ' + $t.State); Write-Host ('Ultima/Last  : ' + $i.LastRunTime + '  (' + $i.LastTaskResult + ': 0=OK, 1=cooldown)'); Write-Host ('Proxima/Next : ' + $i.NextRunTime)"
echo.
echo --- vote.log ---
powershell -ExecutionPolicy Bypass -Command "if (Test-Path '%~dp0vote.log') { Get-Content '%~dp0vote.log' -Tail 6 } else { Write-Host 'no log yet / aun no hay registro' }"
echo.
pause
