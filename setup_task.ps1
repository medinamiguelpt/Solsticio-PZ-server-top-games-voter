param([string]$lang = "es")
# Registers a Windows Scheduled Task that runs the voter every 2h 2m.
# Usually launched by 3-SCHEDULE-every-2h.bat, but you can run it directly too.

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
if (-not $pyw) {
    if ($lang -eq "en") { throw "Python not found on PATH. Install Python first." }
    else { throw "No se encontro Python. Instala Python primero." }
}

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

$next = (Get-ScheduledTaskInfo -TaskName $taskName).NextRunTime
Write-Host ""
if ($lang -eq "en") {
    Write-Host "DONE. It will vote automatically every 2 hours. Next run: $next"
    Write-Host ""
    Write-Host "IMPORTANT:"
    Write-Host "  - Stay LOGGED IN to Windows (the captcha needs a visible window)."
    Write-Host "  - Keep the VPN OFF (vote on your normal home connection)."
    Write-Host "  - A Chrome window flashes for ~8-10s each run; that's normal."
} else {
    Write-Host "LISTO. Votara automaticamente cada 2 horas. Proxima vez: $next"
    Write-Host ""
    Write-Host "IMPORTANTE:"
    Write-Host "  - Manten la sesion de Windows INICIADA (la verificacion necesita ventana visible)."
    Write-Host "  - Manten la VPN APAGADA (vota con tu conexion normal de casa)."
    Write-Host "  - Una ventana de Chrome aparece ~8-10s en cada voto; es normal."
}
