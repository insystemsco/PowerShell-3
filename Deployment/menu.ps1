#Requires -RunAsAdministrator

<#
  .DESCRIPTION
    Simple menu to do a variety of common tasks

  .NOTES
    Author: Carl Hill
    Contact: carl.l.hill@outlook.com

#>


function Menu {

    $title = "Initial Setup Menu"
    $message = "Which script do you want to run?"

        $quit = New-Object System.Management.Automation.Host.ChoiceDescription "&Quit", `
            "Exits the script."
        $networksettings = New-Object System.Management.Automation.Host.ChoiceDescription "&Network Settings", `
            "Configures the network settings."
        $joindomain = New-Object System.Management.Automation.Host.ChoiceDescription "&Join Domain", `
            "Joins the computer to the domain."
        $update = New-Object System.Management.Automation.Host.ChoiceDescription "&Dowload Updates", `
            "Queries the Windows Update server and downloads & installs applicable updates."
        $netfx3 = New-Object System.Management.Automation.Host.ChoiceDescription ".NET &Framework 3", `
            "Installs the .NET 3 Framework."
        $RSAT10 = New-Object System.Management.Automation.Host.ChoiceDescription "&RSAT for Win10", `
            "Installs the Remote System Administration Tools (Active Directory tools) for Windows 10."
        $office = New-Object System.Management.Automation.Host.ChoiceDescription "&Office 2010", `
            "Installs Microsoft Office 2010 SP2."


    $options = [System.Management.Automation.Host.ChoiceDescription[]]($quit, $networksettings, $joindomain, $update, $netfx3, $RSAT10, $office)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result)
        {
            1 {"Configuring network settings..."; NetworkSettings; Pause; Clear-Host; Menu}
            2 {"Now running the domain joining script..."; JoinDomain; Pause; Clear-Host; Menu}
            3 {"Now checking for & installing updates..."; WinUpdate; Pause; Clear-Host; Menu}   
            4 {"Installing .NET Framework 3..."; netfx3; Pause; Clear-Host; Menu}
            5 {"Installing the Remote System Administration Tools for Windows 10..."; RSAT10; Pause; Clear-Host; Menu}
            6 {"Installing Microsoft Office 2010 SP2..."; Office; Pause; Clear-Host; Menu}
            0 {"Goodbye!"; exit} 

        }

}

function NetworkSettings {

# Variables

    $subnet = "192.168.1"
    $MaskBits = 24 # CIDR Notation - This means subnet mask of 255.255.255.0
    $Gateway = "$subnet.1"
    $DNS1 = "192.168.1.40"
    $DNS2 = "8.8.8.8"
    $IPType = "IPv4"
    $Adapter = "Ethernet"

# End variables

    $newIP = Get-Random -Minimum 160 -Maximum 175

# Removes any previous IP settings.  This eliminates errors during script execution.
    Get-NetAdapter -InterfaceAlias $Adapter | Get-NetIPAddress | Remove-NetIPAddress -Confirm:$false
    Remove-NetRoute -InterfaceAlias $Adapter -DestinationPrefix 0.0.0.0/0 -Confirm:$false

# Configure the IP address and default gateway
    
    New-NetIPAddress `
    -InterfaceAlias $Adapter `
    -IPAddress "$subnet.$newIP" `
    -AddressFamily $IPType `
    -PrefixLength $MaskBits `
    -DefaultGateway $Gateway

    Set-DnsClientServerAddress -InterfaceAlias $Adapter -ServerAddresses ($DNS1,$DNS2)

    Start-Sleep -Seconds 2 #delay is required for changes to take effect.

    Write-Host "Assigning IP: $subnet.$newIP"
    Write-Host "Rerun if this IP conflicts..."
    
}


function JoinDomain {

    # Variables
    $subdomain = "images"
    $middomain = "google"
    $tldomain = "com"

    $fulldomain = "$subdomain.$middomain.$tldomain"
    # End Variables

    $UserName = Read-Host 'Enter Your Administrator User Name'
    $Password = Read-Host 'Enter Your Password' -AsSecureString
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $fulldomain\$UserName , $Password 
    
    Add-Computer -DomainName $fulldomain -Credential $Credential -Verbose

    Write-Host "Joining $env:COMPUTERNAME to  $fulldomain in the default container"

    Restart-Computer -Confirm

}

function WinUpdate {

    # Import the module
    Import-Module .\PSWindowsUpdate\PSWindowsUpdate.psm1

    # Runs the PowerShell Windows update script
    Get-WUInstall -AutoReboot -AcceptAll -Verbose

}

function netfx3 {
    
    $Path = "C:\Users\Carl\Downloads"
    Add-WindowsPackage -Online -PackagePath "$Path\microsoft-windows-netfx3-ondemand-package.cab" -Verbose 

}

function RSAT10 {

    $Path = "C:\Users\Carl\Downloads"
    & wusa $Path\WindowsTH-RSAT_WS2016-x64.msu

}

function Office {

    $Path = "C:\Users\Carl\Downloads\Office 2010"
    & $Path\setup.exe

}

Menu