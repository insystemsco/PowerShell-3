<#

.DESCRIPTION
    To remove the DNS record and the Active Directory computer accounts of decommissioned computers.

.NOTES
    Author: Carl Hill
    Contact: carl.l.hill@outlook.com
   
.EXAMPLE
    Create a CSV file:

    ComputerName,Computer Owner
    Computer-001,Matt Damon
    Computer-002,Jimmy Fallon
    Computer-003,Sam Jackson

    Use the -computerlist or -csv parameter to specify the .CSV
    .\cleanup -computerlist mylist.csv
    .\cleanup -csv mylist.csv
#>

#Requires -RunAsAdministrator
#Requires -Version 4

Param(
    [Parameter(Mandatory=$True)]
    [alias("csv")]
    [string]$computerlist
    
)

# Start Variables

$ZoneName = "sub.karl.lab"
$DNSserver = "karl-dc-1"
$logpath = "C:\logs"
$date = Get-Date -Format u

# End Variables

Start-Transcript -Path $logpath\LCR_cleanup_$date.txt -Append -Force

# Gathers the contents of the CSV file and removes the computers from Active Directory
Import-Csv $computerlist | ForEach-Object{
    Remove-ADcomputer -Identity $_.ComputerName -Confirm -Verbose
}

# Gathers the contents of the CSV file and removes the DNS records from the DC on the domain
Import-Csv $computerlist | ForEach-Object{
    if($_.ComputerName -eq $null){
        Write-Host "No DNS record found for" $_.ComputerName
    } 
    else {
        Remove-DnsServerResourceRecord `
        -ZoneName $ZoneName `
        -ComputerName $DNSserver `
        -RRType A `
        -Name $_.ComputerName `
        -ErrorAction SilentlyContinue `
        -Verbose # By default, the cmdlet prompts for confirmation.  Use -Force or -Confirm:$false to ignore
        }
    
}

Stop-Transcript

# GUI box    
$msgBoxInput =  [System.Windows.MessageBox]::Show('Would you like to view the log files now?','Action Complete!','YesNo','Exclamation')

switch  ($msgBoxInput) {
    'Yes' {& notepad.exe $logpath\LCR_cleanup_$date.txt}
    'No' {exit}
}

Pause