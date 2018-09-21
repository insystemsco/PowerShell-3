function Restore-UserProfile {
    
    <#
   .SYNOPSIS
       Restores a backup of a user profile folder.
   
   .DESCRIPTION

        
   .PARAMETER UserProfileName
       The name of the user profile folder.
   
   .EXAMPLE
       Restore-UserProfile -ComputerName ASDF1234 -UserProfileName SamAccountName

   .NOTES

    
   #>
    
   [CmdletBinding()]
   Param(
       [Parameter(Mandatory=$True)]
       [ValidateNotNullOrEmpty()]
       [string]$ComputerName,

       [Parameter(Mandatory=$True)]
       [ValidateNotNullOrEmpty()]
       [string]$UserProfileName
   
   )
 
    BEGIN {
        
        $StopWatch = [System.Diagnostics.Stopwatch]::startNew()
        $date = Get-Date -Format yyyy-MM-dd_HHmmss
        $logpath = "\\server\share\SCRIPTS\logs"
        $logfile = "Restore-UserProfile - $($UserProfileName) - $($ComputerName) $($date).txt"
        Start-Transcript -Path $logpath\$logfile -Append -Force
        
        $BackupShare = "\\server\share"
    
    }
    
    
    PROCESS {

    Copy-Item $BackupShare\$UserProfileName\* '\\$ComputerName\c$\Users\$UserProfileName\' -Verbose -Recurse

    }

    END {
    
        $StopWatch.Stop()
        Write-Output "Backup Restore completed in $($StopWatch.Elapsed.TotalMinutes) minutes."
        Stop-Transcript

    }

}
