
$updatedir = "\\server\share\folder\updates"

$I = 1
$updatecount = (Get-ChildItem -Path $updatedir | Measure-Object).Count

Get-ChildItem -Path $updatedir | ForEach-Object {
    Write-Host "Installing update" $I "of" $updatecount ":" $_.Name
    wusa.exe $_.Name /quiet /norestart
    $I++
}