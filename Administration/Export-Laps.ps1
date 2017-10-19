function Export-Laps {
    
    <#
   .SYNOPSIS
       Exports the LAPS passwords to a CSV.
   
   .DESCRIPTION
       Used when LAPS account passwords need to be saved in a file for reference.
       Commom scenario is when a computer object has been deleted from Active Directory, object restoration is not possible, and HDD is encrypted.
        
   .PARAMETER ExportPath
       The location where the CSV file is to be saved.
   
   .EXAMPLE
       Export-Laps -ExportPath \\server\share\folder

    .NOTES
       Contact: carl.l.hill@outlook.com
   #>
    
   [CmdletBinding()]
   Param(
       [Parameter(Mandatory=$True)]
       [ValidateNotNullOrEmpty()]
       [string]$ExportPath
   
   )
   

$date = Get-Date -Format yyyy-MM-dd_HHmmss

Get-ADComputer -Filter * -SearchBase 'OU=Computers,DC=karl,DC=lab' -Properties Local-Adm-Pwd | 

    ForEach-Object {
        New-Object psobject -Property @{
        ComputerName = $_.Name
        LapsLocalPW = $_.'Local-Adm-Pwd'
        }
    } |
    Export-Csv -Path $ExportPath\localpw-$date.csv -NoTypeInformation
    
}