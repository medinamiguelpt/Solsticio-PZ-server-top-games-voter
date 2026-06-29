# Removes the scheduled voting task.
# Right-click -> "Run with PowerShell".
$taskName = "Solsticio PZ Voter"
try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "Removed scheduled task '$taskName'."
} catch {
    Write-Host "Task '$taskName' not found (nothing to remove)."
}
