# Registers a Windows Scheduled Task that runs the voter every 2h 2m.
# Right-click this file -> "Run with PowerShell"  (or run it in a terminal).

$ErrorActionPreference = "Stop"
$dir = $PSScriptRoot
$taskName = "Solsticio PZ Voter"

# Find pythonw.exe (runs without a console window).
$pyw = $null
$cmd = Get-Command pythonw.exe -ErrorAction SilentlyContinue
if ($cmd) { $pyw = $cmd.Source }
if (-not $pyw) {
    $py = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($py) {
        $cand = Join-Path (Split-Path $py.Source) "pythonw.exe"
        if (Test-Path $cand) { $pyw = $cand } else { $pyw = $py.Source }
    }
}
if (-not $pyw) { throw "Python not found on PATH. Install Python first." }

Write-Host "Using interpreter: $pyw"
Write-Host "Script folder    : $dir"

$action  = New-ScheduledTaskAction -Execute $pyw -Argument "vote.py" -WorkingDirectory $dir
$trigger = New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes(2)) `
            -RepetitionInterval (New-TimeSpan -Hours 2 -Minutes 2) `
            -RepetitionDuration (New-TimeSpan -Days 3650)
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -StartWhenAvailable -MultipleInstances IgnoreNew `
            -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" `
            -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
    -Settings $settings -Principal $principal `
    -Description "Votes for the Solsticio PZ server on top-games.net every 2h2m (nodriver/Turnstile). Idempotent: skips when on cooldown." -Force | Out-Null

Write-Host ""
Write-Host "DONE. Task '$taskName' created. Next run:" (Get-ScheduledTaskInfo -TaskName $taskName).NextRunTime
Write-Host ""
Write-Host "IMPORTANT:"
Write-Host "  - Stay LOGGED IN to Windows (the captcha needs a visible window)."
Write-Host "  - Keep the VPN OFF (vote on your normal home IP)."
Write-Host "  - A Chrome window flashes for ~8-10s each run; that's normal."
Write-Host "  - Check progress: Get-Content `"$dir\vote.log`" -Tail 20"
