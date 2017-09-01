 <#

.DESCRIPTION
    mass adding users to AD group membership

.NOTES
    Author: Carl Hill
    Contact: carl.l.hill@outlook.com

#>

　
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$spreadsheet
)

## Start Variables ##
$logpath = "\\server\share\SCRIPTS\Mass Group Add\logs"
$date = Get-Date -Format yyyy-MM-dd_HHmmss
[string]$logfile = "$($date).txt"
## End variables ##

Start-Transcript -Path "$logpath\$logfile" -Append

　
$userlist = Import-Csv $spreadsheet

foreach ($user in $userlist) {

$UPN = "$($user.ID)@TLD"
$account = (Get-ADUser -Filter {UserPrincipalName -eq $UPN}).DistinguishedName
$AccountName = (Get-ADUser -Filter {UserPrincipalName -eq $UPN}).Name

$group = "$($user.Group)"
$groupcn = (Get-ADGroup -Filter {CN -eq $group}).DistinguishedName
Write-Output "Adding $AccountName to $group"
Add-ADGroupMember -Identity $groupcn -Members $account -Confirm 
}

Stop-Transcript 
