<#

.DESCRIPTION
    To transfer data from a set of computers using a CSV file, going line by line from a source computer to a target computer.

.NOTES
    Author: Carl Hill
    Contact: carl.l.hill@outlook.com
   
.EXAMPLE
    Create a .csv file using the below format:

    Source,Target
    source001,target001
    source002,target002
    source003,target003

    Use the -computerlist or -csv parameter
    .\data-transfer -computerlist mylist.csv
    .\data-transfer -csv mylist.csv

#>

#Requires -RunAsAdministrator

Param(
    [Parameter(Mandatory=$True)]
    [alias("csv")]
    [string]$computerlist
)

# Functions (for brevity)
function stageprogress {
    Write-Progress -Id 2 -Activity "Transferring Data" -Status "$s" -CurrentOperation "Copying $Source to $Target" -PercentComplete (0)
}

function stagecomplete {
    Write-Host "Stage" $s "Complete"
}

# Start Variables
$logpath = "C:\Users\$env:USERNAME\Documents\copylogs"
$i = 0
$total = $computerlist.Count
# End Variables

foreach ($computer in $csv) {

    $Source = $computer.Source
    $Target = $computer.Target

    Start-Transcript -Path "$logpath\$Source to $Target-log.txt" -Force -Append

    $i++
    $s = 1 # resets the Stage number to 1 for each computer pair
    
    Write-Progress -Id 1 -Activity "Transferring dataset $i of $total" -PercentComplete (($i-1) /$total *100)

    # Stage 1
        stageprogress
        Start-Sleep -Seconds 1 # simulates an action
        # Copy-Item -Path \\$Source\C$\filepath -Destination \\$Target\C$\otherfilepath
        stagecomplete
        $s++
        
    # Stage 2
        stageprogress
        Start-Sleep -Seconds 2 
        stagecomplete
        $s++

    # Stage 3
        stageprogress
        Start-Sleep -Seconds 3
        stagecomplete
        $s++

    # Stage 4
        stageprogress
        Start-Sleep -Seconds 4
        stagecomplete
        $s++

    # All Stages Complete
        Write-Progress -Id 2 -Activity "Transferring Data" -Status "All Stages Complete" -CurrentOperation "Copying $Source to $Target" -PercentComplete (100)
        Write-Host "All Stages Complete"
        Start-Sleep -Seconds 2
    
    Stop-Transcript

}

Write-Progress -Id 1 -Activity "Transferring dataset $i of $total" -PercentComplete (($i) /$total *100)

# GUI box    
$msgBoxInput =  [System.Windows.MessageBox]::Show('Would you like to view the log files now?','Data Transfer Complete!','YesNo','Exclamation')

switch  ($msgBoxInput) {
    'Yes' {& explorer.exe $logpath}
    'No' {exit}
}
