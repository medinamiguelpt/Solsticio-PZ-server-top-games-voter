param([string]$lang = "es")
# Removes the scheduled voting task.
$taskName = "Solsticio PZ Voter"
try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    if ($lang -eq "en") { Write-Host "Removed scheduled task '$taskName'." }
    else { Write-Host "Tarea programada '$taskName' eliminada." }
} catch {
    if ($lang -eq "en") { Write-Host "Task '$taskName' not found (nothing to remove)." }
    else { Write-Host "No se encontro la tarea '$taskName' (nada que eliminar)." }
}
