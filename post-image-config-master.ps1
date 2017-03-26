#Requires -RunAsAdministrator

<#
  .DESCRIPTION
    Assigns a static IP then pings the domain.  If the ping fails, it'll assign another IP and ping the domain again.
    Once the ping is successful, it will join the domain. 

  .NOTES
    Author: Carl Hill
    Contact: carl.l.hill@outlook.com

#>


# Start Variables - These should be the only things that would need to be changed for different networks.

    $subdomain = "testing"
    $rootdomain = "carl"
    $tldomain = "lab"
    
    $rootOU = "StarWars"
    $childOU = "Workstations"

    $newIP = 160
    $subnet = "192.168.1"
    $MaskBits = 24 # CIDR Notation - This means subnet mask of 255.255.255.0
    $Gateway = "$subnet.1"
    $DNS1 = "192.168.1.40"
    $DNS2 = "8.8.8.8"
    $IPType = "IPv4"
    $Adapter = "Ethernet"

# End variables


$fulldomain = "$subdomain.$rootdomain.$tldomain"

Start-Transcript -Path "C:\PostImageConfig_log.txt" -Append

$UserName = Read-Host 'Enter Your Administrator User Name'
$Password = Read-Host 'Enter Your Password' -AsSecureString


# Rename computer menu

    $title = "Rename Computer"
    $message = "Would you like to rename the computer? (Currently named $env:COMPUTERNAME)?"
 
        $rename_no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
            "Joins the domain with the Copmuter Name: $env:COMPUTERNAME"

        $rename_yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
            "Renames the computer when joining the domain."

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($rename_no, $rename_yes)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result)
        {
            0 {$newcomputername = Get-WmiObject -Class win32_computersystem | ForEach-Object {$_.Name}} 
            1 {$newcomputername = Read-Host "Enter the new Computer Name"}
        }


# Choose the OU menu
    $title = "Choose OU"
    $message = "To which OU is $newcomputername going?"

        $quit = New-Object System.Management.Automation.Host.ChoiceDescription "&Quit"
        $OU01 = New-Object System.Management.Automation.Host.ChoiceDescription "OU0&1"
        $OU02 = New-Object System.Management.Automation.Host.ChoiceDescription "OU0&2"
        $OU03 = New-Object System.Management.Automation.Host.ChoiceDescription "OU0&3"
        $OU04 = New-Object System.Management.Automation.Host.ChoiceDescription "OU0&4"
        $OU05 = New-Object System.Management.Automation.Host.ChoiceDescription "OU0&5"
        $OU06 = New-Object System.Management.Automation.Host.ChoiceDescription "OU0&6"
        $OU07 = New-Object System.Management.Automation.Host.ChoiceDescription "OU0&7"
        $OU08 = New-Object System.Management.Automation.Host.ChoiceDescription "OU0&8"
        $OU09 = New-Object System.Management.Automation.Host.ChoiceDescription "OU0&9"
        $OUA = New-Object System.Management.Automation.Host.ChoiceDescription "OU&A"
        $OUB = New-Object System.Management.Automation.Host.ChoiceDescription "OU&B"
               

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($quit, $OU01, $OU02, $OU03, $OU04, $OU05, $OU06, $OU07, $OU08, $OU09, $OUA, $OUB)
        
    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    switch ($result)
        {
            0 {$quit = "Goodbye!"; exit}
            1 {$subOU = "OU01"}
            2 {$subOU = "OU02"}
            3 {$subOU = "OU03"}
            4 {$subOU = "OU04"}
            5 {$subOU = "OU05"}
            6 {$subOU = "OU06"}
            6 {$subOU = "OU07"}
            6 {$subOU = "OU08"}
            6 {$subOU = "OU09"}
            6 {$subOU = "OUA"}
            6 {$subOU = "OUB"}

        }

Write-Host -ForegroundColor Yellow "$newcomputername " -NoNewLine; 
Write-Host "will be joined to " -NoNewLine; `
Write-Host -ForegroundColor Yellow "$fulldomain " -NoNewLine; `
Write-Host "in the " -NoNewLine; `
Write-Host -ForegroundColor Yellow "$subOU " -NoNewLine; `
Write-Host "Organizational Unit."

Start-Sleep -Seconds 2


# auto-network-settings

# Configure the DNS client server IP addresses
Write-Progress -Activity "Configuring IP..." -Status "Working..." -CurrentOperation "Setting DNS to $DNS1 and $DNS2"
Set-DnsClientServerAddress -InterfaceAlias $Adapter -ServerAddresses ($DNS1,$DNS2)

# Disables IPv6
Write-Progress -Activity "Configuring IP..." -Status "Working..." -CurrentOperation "Disabling IPv6"
Disable-NetAdapterBinding -InterfaceAlias $Adapter -ComponentID ms_tcpip6

# Removes any previous IP settings.  This eliminates errors during script execution.
Write-Progress -Activity "Configuring IP..." -Status "Working..." -CurrentOperation "Removing previous IP settings"
Get-NetAdapter -InterfaceAlias $Adapter | Get-NetIPAddress | Remove-NetIPAddress -Confirm:$false
Remove-NetRoute -InterfaceAlias $Adapter -DestinationPrefix 0.0.0.0/0 -Confirm:$false
   
# Configure the IP address and default gateway
Write-Progress -Activity "Configuring IP..." -Status "Trying Initial IP:" -CurrentOperation "$subnet.$newIP"
New-NetIPAddress `
-InterfaceAlias $Adapter `
-IPAddress "$subnet.$newIP" `
-AddressFamily $IPType `
-PrefixLength $MaskBits `
-DefaultGateway $Gateway

Start-Sleep -Seconds 4 # 4-second delay is required for changes to take effect.  If fewer, the first connection attempt will fail


function NewNetConfig {

    Write-Progress -Activity "IP Configuration" -Status "Trying IP $subnet.$newIP" -CurrentOperation "Reconfiguring..."
    Get-NetAdapter -InterfaceAlias $Adapter | Get-NetIPAddress | Remove-NetIPAddress -Confirm:$false
   
    # Configure the IP address and default gateway
    New-NetIPAddress -InterfaceAlias $Adapter -IPAddress "$subnet.$newIP" -AddressFamily $IPType -PrefixLength $MaskBits
    Start-Sleep -Seconds 4

}

#  Tests the network connection and keeps adding 1 to the IP until it succeeds

Do {
      
    Write-Progress -Activity "IP Configuration" -Status "Trying IP $subnet.$newIP" -CurrentOperation "Attempting connection..."  
   

    if(Test-Connection -Computername "$fulldomain" -BufferSize 16 -Count 2 -Quiet) {
        Write-Progress -Activity "IP Configuration" -Status "Trying IP $subnet.$newIP" -CurrentOperation "Success!"
       
        $iptest = "success"
    }

    # Stops the loop if it reaches a max of 175
    elseif ($newIP -eq 175) {
       For ($i=5; $i -gt 1; $i–-) {Write-Progress -Activity "IP Configuration" -Status "Tried all allocated IPs" -CurrentOperation "Exiting the script! Check C:\PostImageConfig_log.txt for details."
        Start-Sleep -Seconds 1}
          
        Stop-Transcript
        exit
        }

    else {
        Write-Progress -Activity "IP Configuration" -Status "Trying IP $subnet.$newIP" -CurrentOperation "Failed!"
        $iptest = "fail"
        Start-Sleep -Seconds 1 # 1 second delay to all enough time to show failure in the progress bar
        $newIP = $newIP+1
        NewNetConfig
    }
} #end of Do

Until ($iptest -eq "success")


$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $fulldomain\$UserName , $Password 

    Write-Progress -Activity "Joining Domain" -Status "joining..." -CurrentOperation "$newcomputername is joining the $fulldomain in the $subOU OU"
    
# Script aborts if the Add-Computer command is executed when the -NewName is the same as $env:COMPUTERNAME

    if ($env:COMPUTERNAME -match $newcomputername) {
        Add-Computer -DomainName $fulldomain `
        -Credential $Credential `
        -OUPath "OU=$childOU,OU=$subOU,OU=$rootOU,DC=$subdomain,DC=$rootdomain,DC=$tldomain" `
        -Verbose
    }
    
    else{
        Add-Computer -DomainName $fulldomain `
        -Credential $Credential `
        -NewName $newcomputername `
        -OUPath "OU=$childOU,OU=$subOU,OU=$rootOU,DC=$subdomain,DC=$rootdomain,DC=$tldomain" `
        -Verbose
        }

    # Initiates a 5 second countdown in case you need to Ctrl+C to stop the script.
  For ($i=5; $i -gt 1; $i–-) {  
    Write-Progress -Activity "Joining Domain" -Status "$newcomputername has joined $fulldomain" -CurrentOperation "Rebooting..." -SecondsRemaining $i
    Start-Sleep 1
}

    Stop-Transcript
    Restart-Computer

