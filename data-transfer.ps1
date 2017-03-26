<#

.DESCRIPTION
    To transfer data from a set of computers using a CSV file, going line by line from a source computer to a target computer.

.NOTES
    Author: Carl Hill
    Contact: carl.l.hill@outlook.com
   
.EXAMPLE
    Create a file named transferlist.csv in the same folder as this script.

    Source,Target
    source001,target001
    source002,target002
    source003,target003
#>

$logpath = "C:\Users\$env:USERNAME\Documents\copylogs"
$csv = Import-Csv .\transferlist.csv
$i = 0
$total = $csv.Count

foreach ($computer in $csv) {

    $Source = $computer.Source
    $Target = $computer.Target

    Start-Transcript -Path "$logpath\$Source to $Target-log.txt" -Force

    $i++


    Write-Progress -Id 1 -Activity "Transferring dataset $i of $total" -PercentComplete (($i-1) /$total *100)

    # Stage 1
        Write-Progress -Id 2 -Activity "Transferring Data" -Status "Stage 1" -CurrentOperation "Copying $Source to $Target" -PercentComplete (0)
        Start-Sleep -Seconds 2 # this simulates an operation such as copying files from $Source to $Target
        # Copy-Item -Path \\$Source\C$\filepath -Destination \\$Target\C$\otherfilepath
        Write-Host "Stage 1 Complete"

    # Stage 2
        Write-Progress -Id 2  -Activity "Transferring Data" -Status "Stage 2" -CurrentOperation "Copying $Source to $Target" -PercentComplete (25)
        Start-Sleep -Seconds 2
        Write-Host "Stage 2 Complete"

    # Stage 3
        Write-Progress -Id 2 -Activity "Transferring Data" -Status "Stage 3" -CurrentOperation "Copying $Source to $Target" -PercentComplete (50)
        Start-Sleep -Seconds 2
        Write-Host "Stage 3 Complete"

    # Stage 4
        Write-Progress -Id 2 -Activity "Transferring Data" -Status "Stage 4" -CurrentOperation "Copying $Source to $Target" -PercentComplete (75)
        Start-Sleep -Seconds 2
        Write-Host "Stage 4 Complete"

    # All Stages Complete
        Write-Progress -Id 2 -Activity "Transferring Data" -Status "All Stages Complete" -CurrentOperation "Copying $Source to $Target" -PercentComplete (100)
        Write-Host "All Stages Complete"
        Start-Sleep -Seconds 2
        Stop-Transcript

}

Write-Progress -Id 1 -Activity "Transferring dataset $i of $total" -PercentComplete (($i) /$total *100)
    Start-Sleep -Seconds 3
