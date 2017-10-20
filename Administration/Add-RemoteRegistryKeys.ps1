function Add-RemoteRegistryKeys {

<#
  .SYNOPSIS
  Adds 2 Registry Keys to a remote computer.

  .DESCRIPTION
  Adds the google.com to the Trusted Sites (Zone to Assignment List).

  .EXAMPLE
  Add-RemoteRegistryKeys -ComputerName REMOTECOMPUTER

  .PARAMETER COMPUTERNAME
  Specify the computer name or IP address to preform the remote registry edit.

   .NOTES
   Contact: carl.l.hill@outlook.com
  #>



[CmdletBinding()]
param (
    [Parameter(Mandatory=$True)]
    [string]$ComputerName
)

    BEGIN {}
        
     

    PROCESS {
        Write-Output "Setting Registry Key for google.com"
        psexec.exe -s \\$ComputerName powershell.exe -command "New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey' -Name '*.google.com' -PropertyType String -Value 1 -Verbose"
        
        Write-Output "Setting Registry Key for maps.google.com"
        psexec.exe -s \\$ComputerName powershell.exe -command "New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey' -Name '*.maps.google.com' -PropertyType String -Value 1 -Verbose"

        Write-Output "Forcing a Group Policy Update..."
        psexec.exe -s \\$ComputerName powershell.exe -command "gpupdate /force"
        }

    END {}


}

