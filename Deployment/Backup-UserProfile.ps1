function Backup-UserProfile {
    
    <#
   .SYNOPSIS
       Creates a backup of a user profile folder.
   
   .DESCRIPTION
        Creates a folder on the Win10 migration share and copies the user profile folder from a network computer to the share.
        Performs a search for all PST files and moves to the Desktop folder.
        Modifies the Share folder's ACL to add a security group(s) with full contol.
        Then performs a recursive copy of the user profile folder.
        Excludes the PowerShell transcripts in the Documents folder.
        Excludes IE cache folders.

        
   .PARAMETER UserProfileName
       The name of the user profile folder.
   
   .EXAMPLE
       Backup-UserProfile -ComputerName ASDF1234 -UserProfileName 1234567890.sam

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
        
        $BackupShare = "\\server\share"
        
        
        # Set IE cache location based on OS version

        if ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName).Name -match "Windows 7") {
            
            Write-Verbose "OS is Windows 7"
            $ExcludeItems = @(
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Local\Microsoft\Internet Explorer\IECompatData\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Local\Microsoft\Feeds Cache\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Local\Microsoft\Windows\WebCache\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Local\Microsoft\Windows\History\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Local\Microsoft\Windows\Temporary Internet Files\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Local\Temp\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\LocalLow\Microsoft\Internet Explorer\DOMStore\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Roaming\Microsoft\Internet Explorer\UserData\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Roaming\Microsoft\Windows\Cookies\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Roaming\Microsoft\Windows\DNTException\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Roaming\Microsoft\Windows\IECompatCache\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Roaming\Microsoft\Windows\IECompatUACache\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Roaming\Microsoft\Windows\IEDownloadHistory\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Roaming\Microsoft\Windows\IETldCache\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Roaming\Microsoft\Windows\PrivacIE\"
            )
        }

        elseif ((Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName).Name -match "Windows 10") {
            
            Write-Verbose "OS is Windows 10"
            $ExcludeItems = @(
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Local\Temp"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Local\Microsoft\INetCache"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Local\Packages\Microsoft.MicrosoftEdge*\AC\#!001\MicrosoftEdge\Cache\"
                "\\$ComputerName\C$\Users\$UserProfileName\AppData\Roaming\Microsoft\Internet Explorer\UserData\"
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
            "Administrators"
            "Domain Admins"
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


            # Search for all PSTs and moves them to Desktop folder if they are outside of the profile folder.
            
            Write-Output "Searching for PSTs..."
            Get-Childitem –Path "\\$ComputerName\C$\" -Include *.pst -File -Recurse -ErrorAction SilentlyContinue |
            ForEach-Object {
                Write-Output "Found $_"
                "$_" >> \\$ComputerName\C$\Users\$UserProfileName\Documents\PSTs.txt
                if ("$_" -notmatch "$UserProfileName") {
                    Move-Item $_ "\\$BackupShare\$UserProfileName\Documents\Outlook Files" -Verbose
                }
            }


           # Remove PowerShell transcript folders from Documents & the IE Cache
            Write-Output "Removing the PowerShell transcript folders from Documents..."
            $ri = 0
            $rmtotal = (Get-Childitem "\\$ComputerName\C$\Users\$UserProfileName\Documents\201*" -Directory).Count

            Get-Childitem "\\$ComputerName\C$\Users\$UserProfileName\Documents\201*" -Directory |
            ForEach-Object {
                $ri++
                Write-Progress -Activity "Deleting PowerShell Transcripts from Documents" -Status "Removing item $ri of $rmtotal" -PercentComplete (($ri/$rmtotal)*100)
                Remove-Item $_.FullName -Verbose -Recurse -Force  
            }
            
            Remove-Item $ExcludeItems -Verbose -Recurse -Force 
             

            # Copies the user profile folder to server & excludes all folders in $ExcludeItems
            Write-Verbose "Now copying $UserProfileName from $ComputerName to $BackupShare..." -Verbose
          
            robocopy \\$ComputerName\C$\Users\$UserProfileName $BackupShare\$UserProfileName /E /XJ /V /XD \\$ComputerName\C$\Users\$UserProfileName\Documents\201* /XF *.ost
    
    }
    
    END {
        $StopWatch.Stop()
        Write-Output "Backup completed in $($StopWatch.Elapsed.TotalMinutes) minutes."
        Stop-Transcript
    }
}
