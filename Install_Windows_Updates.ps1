#Requires -RunAsAdministrator

<#
  .DESCRIPTION
    Offline update installer.

  .NOTES
    Author: Carl Hill
    Contact: carl.l.hill@outlook.com

#>

# Start Variables
$updatedir = "\\server\share\folder\updates"
$I = 1 #interval
# End Variables

Get-ChildItem -Path $updatedir *.msu | ForEach-Object {
    Write-Host "Installing Windows Update" $I "of" (Get-ChildItem).Count ":" $_.Name
    wusa.exe $_.Name /quiet /norestart
    $I++
}

# Windows Malicious Software Removal Tool
Get-ChildItem $updatedir\windows-*.exe | ForEach-Object {
Write-Host "Installing" $_.Name "..."
Start-Process $_  -ArgumentList /q -Wait
}

# Microsoft Silverlight Security Updates
Get-ChildItem $updatedir\silverlight*.exe | ForEach-Object {
Write-Host "Installing" $_.Name "..."
Start-Process $_  -ArgumentList /q, /ignorewarnings -Wait
}

