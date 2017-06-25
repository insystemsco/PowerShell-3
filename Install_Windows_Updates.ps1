#Requires -RunAsAdministrator

<#
  .DESCRIPTION
    Offline update (.msu files) installer.

  .NOTES
    Author: Carl Hill
    Contact: carl.l.hill@outlook.com

#>

# Start Variables
$updatedir = "\\server\share\folder\updates"
$I = 1 #interval
# End Variables

Get-ChildItem -Path $updatedir| ForEach-Object {
    Write-Host "Installing update" $I "of" (gci).Count ":" $_.Name
    wusa.exe $_.Name /quiet /norestart
    $I++
}