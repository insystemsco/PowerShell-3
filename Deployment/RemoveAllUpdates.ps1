$updates = Get-HotFix

foreach ($update in $updates) {
    Write-Output "Uninstalling $($update.HotFixID)"
    Start-Process wusa.exe -ArgumentList /uninstall "/kb:$(($update.HotFixID).Substring(2))", /quiet, /norestart -Wait
}
