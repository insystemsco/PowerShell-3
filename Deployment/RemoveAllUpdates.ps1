Get-Hotfix | ForEach-Object {
    Start-Process wusa.exe -ArgumentList /uninstall, /$_.HotFixID, /quiet, /norestart
}