$UpdateExePath = "C:\Updates\Office\2016"
$MSPPath = "\\MDT\DepShare$\Scripts\Custom\Updates\Office\2016"

Get-ChildItem -Path $UpdateExePath -Filter *.exe | ForEach-Object {Start-Process $_.FullName -ArgumentList "/extract:.\", /q -Wait}
Copy-Item $UpdateExePath\*.msp -Desktination $MSPPath -Verbose
