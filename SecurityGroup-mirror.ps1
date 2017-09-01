 <#

.DESCRIPTION
    Mirrors the security group membership of one Active Directory account to another.

.NOTES
    Author: Carl Hill
    Contact: carl.l.hill@outlook.com

    User account names is their email address without the @mail.com
    Account names

    The target account is the account requesting permissions
    The source account is the account that the requester mirrors
   
#>

# Requires the Source and Target inputs as parameters
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [alias("Source")]
    [string]$SourceName,

    [Parameter(Mandatory=$True)]
    [alias("Target")]
    [string]$TargetName
)

## Start Variables ##
$logpath = "\\server\share\SCRIPTS\Security Group Mirror\logs"
$date = Get-Date -Format yyyy-MM-dd_HHmmss
[string]$logfile = "$($SourceName) to $($TargetName) - $($date).txt"
## End variables ##

Start-Transcript -Path "$logpath\$logfile" -Append

　
# Converts account Names to SamAccountNames
$SourceSAM = (Get-ADUser -Filter {Name -eq $SourceName}).SamAccountName
$TargetSAM = (Get-ADUser -Filter {Name -eq $TargetName}).SamAccountName

　
　
# Checks for users' account existence.

$UserList = @("$SourceSAM", "$TargetSAM")
foreach ($u in $UserList) {
    try {$existinguser = Get-ADUser -Identity $u -ErrorAction Stop}
    catch{
    if ($_ -like "*Cannot find an object with identity: '$u'*") {"User '$u' does not exist."}
        else {"An error occurred: $_"}
        continue
        }
    "User '$($existinguser.SamAccountName)' exists."

　
    "both users exist... now adding groups to $TargetName"

    # Gathers all of the SGs that the source account is a member of
    $groups = Get-ADUser $SourceSAM -Properties memberof | Select-Object -ExpandProperty memberof

    # Gets the group names and presents it a cleaner way than an LDAP query
    $grouplist = $groups | Get-adgroup | ForEach-Object {$_.Name}

    Write-Host "$TargetName ($TargetSAM) to be added to the following groups: `n"

    # Displays the User's Group Membership
    $grouplist

　
    $groups | Add-ADGroupMember -Members $TargetSAM -Confirm
}

　
  Stop-Transcript 
