param([string]$lang = "es")
# Registers a Windows Scheduled Task that runs the voter every 2h 2m.
# Usually launched by 3-SCHEDULE-every-2h.bat, but you can run it directly too.

$ErrorActionPreference = "Stop"
$dir = $PSScriptRoot
$taskName = "Solsticio PZ Voter"

# Get the REAL interpreter path. Get-Command can return the WindowsApps shim
# (...\WindowsApps\pythonw.exe), which does NOT run reliably under Task
# Scheduler. sys.executable always points at the real install.
$pyexe = $null
try { $pyexe = (& python -c "import sys; print(sys.executable)" 2>$null) } catch {}
if (-not $pyexe) {
    $c = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($c) { $pyexe = $c.Source }
}
if (-not $pyexe) {
    if ($lang -eq "en") { throw "Python not found on PATH. Install Python first." }
    else { throw "No se encontro Python. Instala Python primero." }
}
$pyw = Join-Path (Split-Path $pyexe) "pythonw.exe"
if (-not (Test-Path $pyw)) { $pyw = $pyexe }   # fall back to console python

# Probe the current cooldown so the FIRST vote lands as soon as it ends,
# instead of waiting for the next 2h2m slot. Falls back to 2 minutes.
$first = (Get-Date).AddMinutes(2)
if ($lang -eq "en") { Write-Host "Checking when you can vote next (a Chrome window opens briefly)..." }
else { Write-Host "Comprobando cuando podras votar (se abrira Chrome un momento)..." }
try {
    $probeOut = & $pyexe (Join-Path $dir "vote.py") "--probe" 2>$null
    $m = [regex]::Match((@($probeOut) -join "`n"), 'COOLDOWN_SECONDS=(\d+)')
    if ($m.Success -and [int]$m.Groups[1].Value -gt 0) {
        $first = (Get-Date).AddSeconds([int]$m.Groups[1].Value + 90)
    }
} catch {}

$action  = New-ScheduledTaskAction -Execute $pyw -Argument "vote.py" -WorkingDirectory $dir
$trigger = New-ScheduledTaskTrigger -Once -At $first `
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
