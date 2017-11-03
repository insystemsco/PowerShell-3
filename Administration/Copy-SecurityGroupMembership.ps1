 function Copy-SecurityGroupMembership {
 
 <#
.SYNOPSIS
    Copies the security group membership of one Active Directory user account to another.

.DESCRIPTION
    Used when a user requires the same (or similar) access/permissions to files and folders as another user.
    Gathers all group membership of the source user and adds the target user to those groups.
        -Input the account name
        -Cmdlet requires confirmation before adding a user account to a group.
        -Cmdlet requires domain admin privileges.
        -Cmdlet requires Active Directory PowerShell module.

    
    Contact: carl.l.hill@outlook.com
     
.PARAMETER SourceName
    The source account used as reference to add membership to the target account.

.PARAMETER TargetName
    The account that the membership is added/applied to.

.EXAMPLE
    Copy-SecurityGroupMembership -SourceName bob.m.smith1 -TargetName joe.f.johnson

#>
 
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [Parameter(ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [alias("Source")]
    [string]$SourceName,

    [Parameter(Mandatory=$True)]
    [Parameter(ValueFromPipeline)]
    [ValidateNotNullOrEmpty()]
    [alias("Target")]
    [string]$TargetName
)

    BEGIN {
        $logpath = "\\server\share\folder\logs"
        $date = Get-Date -Format yyyy-MM-dd_HHmmss
        $logfile = "Copy-SecurityGroupMembership - $($SourceName) to $($TargetName) - $($date).txt"

        Start-Transcript -Path "$logpath\$logfile" -Append

        # Converts user object to SamAccountNames
        $SourceSAM = (Get-ADUser -Filter {Name -eq $SourceName}).SamAccountName
        $TargetSAM = (Get-ADUser -Filter {Name -eq $TargetName}).SamAccountName

    }

    PROCESS {
            # Gathers all of the security groups that the source account is a member of
            $groups = Get-ADUser $SourceSAM -Properties memberof | Select-Object -ExpandProperty memberof

            # Presents the group names in a clean way
            Write-Output "$TargetName ($TargetSAM) to be added to the following groups: `n"
            $groups | Get-ADGroup | ForEach-Object {Write-Output "$_.Name"}
    
            # Adds SourceName groups to TargetName
            $groups | Add-ADGroupMember -Members $TargetSAM -Confirm
    }

    END {
        Stop-Transcript
    }
}

Export-ModuleMember -Variable SourceName
Export-ModuleMember -Function Copy-SecurityGroupMembership