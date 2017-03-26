<#

.DESCRIPTION
    To remove the DNS record and the Active Directory computer accounts of decommissioned computers.

.NOTES
    Author: Carl Hill
    Contact: carl.l.hill@outlook.com
   
.EXAMPLE
    Create a file named cleanuplist.csv in the same folder as this script.

    ComputerName,Computer Owner
    Computer-001,Matt Damon
    Computer-002,
    Computer-003
#>

#Requires -RunAsAdministrator
#Requires -Version 4

# Gathers the contents of the cleanuplist.txt file and removes the computers from Active Directory
Import-Csv cleanuplist.csv | ForEach-Object{
    Remove-ADcomputer -Identity $_.ComputerName -Confirm -Verbose
}

$ZoneName = "sub.karl.lab"
$DNSserver = "karl-dc-1"

# Gathers the contents of the cleanuplist.txt file and removes the DNS records from the DC on the domain
Import-Csv cleanuplist.csv | ForEach-Object{
    if($_.ComputerName -eq $null){
        Write-Host "No DNS record found for $_.ComputerName"
    } else {
        Remove-DnsServerResourceRecord `
-ZoneName $ZoneName `
-ComputerName $DNSserver `
-RRType A `
-Name $_.ComputerName `
-ErrorAction SilentlyContinue `
-Verbose # By default, the cmdlet prompts for confirmation.  Use -Force or -Confirm:$false to ignore
    }
    
}

Pause