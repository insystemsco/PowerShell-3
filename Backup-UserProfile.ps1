function Backup-UserProfile {
    
    <#
   .SYNOPSIS
       Creates a backup of a user profile folder.
   
   .DESCRIPTION
        Performs a search for all PST files and moves to the Desktop folder
        Creates a new folder onto the backup server and modifies that folder's ACL to add a security group with full contol.
        Then performs a recursive copy of the user profile folder
        Excludes the PowerShell transcripts in the Documents folder
        Excludes IE & Firefox cache folders

        
   .PARAMETER UserProfileName
       The name of the user profile folder.
   
   .EXAMPLE
       Backup-UserProfile -ComputerName ASDF1234 -UserProfileName 1234567890.ptc

   .NOTES
       Contact: carl.l.hill@outlook.com
    
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
        $logpath = "\\server\share\logs"
        $logfile = "Backup-UserProfile - $($UserProfileName) - $($ComputerName) $($date).txt"
        Start-Transcript -Path $logpath\$logfile -Append -Force
        
        $BackupShare = \\server\share
        
        
        # Set IE cache location based on OS version

        if ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName).Name -match "Windows 7") {
            
            Write-Verbose "OS is Windows 7"
            $ExcludeItems = @(
                "\\$ComputerName\C$\$UserProfileName\AppData\Local\Microsoft\Internet Explorer\IECompatData\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Local\Microsoft\Feeds Cache\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Local\Microsoft\Windows\WebCache\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Local\Microsoft\Windows\History\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Local\Microsoft\Windows\Temporary Internet Files\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Local\Temp\"
                "\\$ComputerName\C$\$UserProfileName\AppData\LocalLow\Microsoft\Internet Explorer\DOMStore\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Roaming\Microsoft\Internet Explorer\UserData\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Roaming\Microsoft\Windows\Cookies\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Roaming\Microsoft\Windows\DNTException\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Roaming\Microsoft\Windows\IECompatCache\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Roaming\Microsoft\Windows\IECompatUACache\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Roaming\Microsoft\Windows\IEDownloadHistory\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Roaming\Microsoft\Windows\IETldCache\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Roaming\Microsoft\Windows\PrivacIE\"
            )
        }

        elseif ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName).Name -match "Windows 10") {
            
            Write-Verbose "OS is Windows 10"
            $ExcludeItems = @(
                "\\$ComputerName\C$\$UserProfileName\AppData\Local\Temp"
                "\\$ComputerName\C$\$UserProfileName\AppData\Local\Microsoft\INetCache"
                "\\$ComputerName\C$\$UserProfileName\AppData\Local\Packages\Microsoft.MicrosoftEdge*\AC\#!001\MicrosoftEdge\Cache\"
                "\\$ComputerName\C$\$UserProfileName\AppData\Roaming\Microsoft\Internet Explorer\UserData\"
            )
        }


        else {
            Write-Output "Could not determine Operating System Version, script will not exclude IE cache"
        }
        
        
    }

    PROCESS {
            New-Item -ItemType Directory -Path $BackupShare\$UserProfileName

            # Set-Acl for IT support security group(s)
            $domain = "karl.lab"
            $SecurityGroups = @(
                "testgroup1"
                "testgroup2"
            )
            
            foreach ($Group in $SecurityGroups) {
                $Acl = Get-Acl "$BackupShare\$UserProfileName"
                $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\$Group", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
                $Acl.SetAccessRule($Ar)
                Set-Acl "$BackupShare\$UserProfileName" $Acl
            }
            
            # Set-Acl for the user who's profile is to be backed up
            $Acl = Get-Acl "$BackupShare\$UserProfileName"
            $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\$UserProfileName", "Read", "ContainerInherit,ObjectInherit", "None", "Allow")
            $Acl.SetAccessRule($Ar)
            Set-Acl "$BackupShare\$UserProfileName" $Acl


            # Search for all PSTs and moves them to Desktop folder.
            # Oftentimes, users leave PSTs in the default AppData folder (which is hidden)
            Write-Verbose "Creating PST folder on the Desktop..."
            New-Item -ItemType Directory -Path \\$ComputerName\C$\Users\$UserProfileName\Desktop\PSTs -Verbose
            
            Write-Verbose "Searching for PSTs..."
            Get-Childitem –Path \\$ComputerName\C$\ -Include *.pst -File -Recurse -ErrorAction SilentlyContinue |
            ForEach-Object {
                Write-Output "Found $_"
                Move-Item -Path $_.FullName -Destination \\$ComputerName\C$\Users\$UserProfileName\Desktop\PSTs -Verbose
            }


            # Remove PowerShell transcript folders from Documents
            Write-Verbose "Removing the PowerShell transcript folders from Documents..."
            $ri = 0
            $rmtotal = (Get-Childitem \\$ComputerName\C$\Users\$UserProfileName\Documents\201* -Directory).Count

            Get-Childitem \\$ComputerName\C$\Users\$UserProfileName\Documents\201* -Directory |
            ForEach-Object {
                $ri++
                Write-Progress -Activity "Deleting PowerShell Transcripts from Documents" -Status "Removing item $ri of $rmtotal" -PercentComplete (($i/$total)*100)
                Remove-Item $_.FullName -Recurse -Force  
            }
            
              
            # Copies the user profile folder to server & excludes all folders in $ExcludeItems
            Write-Verbose "Now copying $UserProfileName from $ComputerName to $BackupShare..."
          
            Get-Childitem \\$ComputerName\C$\Users\$UserProfileName |
            Where-Object {$_.FullName -notin $ExcludeItems} |
            Copy-Item -Destination $BackupShare\$UserProfileName -Exclude $ExcludeItems -Verbose
    
    }
    
    END {
        $StopWatch.Stop()
        Write-Output "Backup completed in $($StopWatch.Elapsed.TotalMinutes) minutes."
        Stop-Transcript
    }
}
