param([int]$rc, [string]$lang = "es")
# Prints the localized result of a vote attempt, and (on success) re-anchors
# the schedule to "now + 2h2m" if the scheduled task exists.

$task = "Solsticio PZ Voter"
$url  = "https://es.top-games.net/project-zomboid/vote/esp-x-latam-la-frontera-b42-pvx-solsticio-pz-server"
function L($es, $en) { if ($lang -eq "en") { $en } else { $es } }

switch ($rc) {
    0 {
        $exists = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
        if ($exists) {
            $at  = (Get-Date).AddHours(2).AddMinutes(1).AddSeconds(30)
            $trg = New-ScheduledTaskTrigger -Once -At $at `
                     -RepetitionInterval (New-TimeSpan -Hours 2 -Minutes 1 -Seconds 30) `
                     -RepetitionDuration (New-TimeSpan -Days 3650)
            Set-ScheduledTask -TaskName $task -Trigger $trg | Out-Null
            Enable-ScheduledTask -TaskName $task | Out-Null
            $next = (Get-ScheduledTaskInfo -TaskName $task).NextRunTime
            Write-Host (L "  VOTO CONFIRMADO! Votaras de nuevo automaticamente en ~2 horas." `
                          "  Vote CONFIRMED! You'll vote again automatically in ~2 hours.")
            Write-Host (L "  (proxima vez automatica: $next)" "  (next automatic vote: $next)")
        } else {
            Write-Host (L "  VOTO CONFIRMADO! Ahora abre SCHEDULE-every-2h.bat para votar automaticamente." `
                          "  Vote CONFIRMED! Now run SCHEDULE-every-2h.bat to vote automatically.")
        }
    }
    1 {
        Write-Host (L "  EN ENFRIAMIENTO - ya votaste en las ultimas ~2 horas." `
                      "  ON COOLDOWN - you already voted in the last ~2 hours.")
        Write-Host (L "  Mira cuanto tiempo falta en esta pagina:" `
                      "  See exactly how much time is left on this page:")
        Write-Host "  $url"
        Write-Host ""
        Write-Host (L "  Para activar el voto automatico, ejecuta SCHEDULE-every-2h.bat:" `
                      "  To turn on automatic voting, run SCHEDULE-every-2h.bat:")
        Write-Host (L "  votara solo en cuanto termine el enfriamiento, y luego cada ~2 horas." `
                      "  it votes by itself as soon as the cooldown ends, then every ~2 hours.")
    }
    2 {
        Write-Host (L "  No paso la verificacion. Apaga la VPN e intenta de nuevo mas tarde." `
                      "  Did not pass the human-check. Turn the VPN off and try again later.")
    }
    default {
        Write-Host (L "  Algo fallo. Abre vote.log para ver el detalle." `
                      "  Something went wrong. Open vote.log to see the details.")
    }
}
