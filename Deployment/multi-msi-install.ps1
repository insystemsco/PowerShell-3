
# Simple script to install multiple msi installer files sequentially
# Useful to consolidate multiple packages for a program install (with dependencies)

$Date = Get-Date -Format yyyyMMddTHHmmss

Start-Transcript -Path "\\SERVER\LOGS\msi-install-logs\$Date - $env:COMPUTERNAME.txt"

Start-Process -FilePath msiexec.exe -ArgumentList /i, foo1.msi, /L*v, /quiet -Wait
Start-Process -FilePath msiexec.exe -ArgumentList /i, foo2.msi, /L*v, /quiet -Wait

Stop-Transcript
