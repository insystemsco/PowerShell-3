<# 
 .DESCRIPTION
  Extracts the MSP files from EXE files and copies to the updates folder for use with MDT/SCCM image creation.
  
 .NOTES
  Author: Carl Hill
  Contact: carl.l.hill@outlook.com
#>

$UpdateExePath = "C:\Updates\Office\2016"
$MSPPath = "\\MDT\DepShare$\Applications\Office 2016\Files\updates"

Get-ChildItem -Path $UpdateExePath -Filter *.exe |
ForEach-Object {Start-Process $_.FullName -ArgumentList "/extract:.\", /q -Wait}

Copy-Item $UpdateExePath\*.msp -Destination $MSPPath -Verbose
