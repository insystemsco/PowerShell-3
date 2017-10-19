 #Requires -RunAsAdministrator 

<# 
   .DESCRIPTION 
     Validates and corrects deficiencies for Windows 10 AGM image. 
  
   .NOTES 
     Author: Carl Hill 
     Contact: carl.l.hill@outlook.com

   .CHANGELOG
    2017-10-10
        Added check for group membership
    2017-10-6
        Added checks for TPM & UEFI
    2017-09-27
        Narrowed list of apps to essential apps
        Transferred app list to arrary in script instead of in apps.txt
        Removed Install All SCCM Apps function

    2017-08-24
        Replaced google.com with local domain for ping test
        Replaced Write-Host with Write-Verbose/Error/Warning/Output
        Simplified Countdown mechanism
        Added BitLocker HDD encryption detection
        Added pending updates detection

  
#> 

$InformationPreference = "Continue"
$errors = 0
$logpath = "\\server\share\folder\logs"
$date = Get-Date -Format yyyy-MM-dd_HHmmss
[string]$logfile =  "Image Validation - $($env:COMPUTERNAME) - $($date).txt"

　
Start-Transcript -Path $logpath\$logfile -Append

　
　
　
# TPM status

　
$TPMStatus = wmic /namespace:\\root\cimv2\security\microsofttpm path win32_tpm get IsActivated_InitialValue

if ($TPMStatus) {
    Write-Output "TPM is Activated"
    }
else {
    Write-Output "TPM is NOT Activated!"
    $errors++
    }

　
# Check for UEFI 

　
Function Get-BiosType {

[OutputType([UInt32])]
Param()

Add-Type -Language CSharp -TypeDefinition @'

    using System;
    using System.Runtime.InteropServices;

    public class FirmwareType
    {
        [DllImport("kernel32.dll")]
        static extern bool GetFirmwareType(ref uint FirmwareType);

        public static uint GetFirmwareType()
        {
            uint firmwaretype = 0;
            if (GetFirmwareType(ref firmwaretype))
                return firmwaretype;
            else
                return 0;   // API call failed, just return 'unknown'
        }
    }
'@

　
    [FirmwareType]::GetFirmwareType()
}

　
Switch (Get-BiosType) {
    1       {Write-Error "Firmware Type is Legacy BIOS";$errors++}
    2       {Write-Output "Firmware is UEFI"}
    Default {Write-Error "Firmware Type is Unknown";$errors++}
    }

　
# check if member of quarantine group

if ((Get-ADComputer $env:ComputerName -Properties memberof) -match "GROUP1" -or "GROUP2") {
    Write-Error "Computer is in GROUP" -Category ResourceExists -RecommendedAction "SCCM Repair"
    $errors++
    }
    else {
        Write-Output "Computer is not in GROUP"
        }

　
　
　
# pings local domain to verify network functionality

    if (Test-Connection -Count 1 domain.local) {
        Write-Output "Network connection to domain.local is successful. `n"
        }

        else {
            Write-Warning "Network connection to domain.local NOT successful! `n"
            }

　
　
　
　
# Checks to see if the Portal page is added into the Site to Zone settings, and adds them if they are not

$portalHKLM1 = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey" -Name "*.domain.local" -ErrorAction SilentlyContinue
$portalHKLM2 = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey" -Name "*.sub.domain.local" -ErrorAction SilentlyContinue

    if ($portalHKLM1.'*.domain.local' -eq 1 -and $portalHKLM2.'*.sub.domain.local' -eq 1) {
        Write-Output "Portal page Site to Zone has been added to Local Group Policy."
    }

　
    else {
        Write-Warning "Portal page Site to Zone has NOT been added to Local Group Policy!"
        Write-Verbose "The Portal page will now be added to the Site to Zone Local Group Policy.."

        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey" -Name "*.domain.local" -PropertyType String -Value 1
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey" -Name "*.sub.domain.local" -PropertyType String -Value 1

    }

　
　
　
　
 #determines if the computer is a laptop and installs VPN client if it is a laptop

Function Get-Laptop
{
 Param(
 [string]$computer = "localhost"
 )
 $isLaptop = $false
 if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | 
    Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 `
    -or $_.chassistypes -eq 14})
   { $isLaptop = $true }
 if(Get-WmiObject -Class win32_battery -ComputerName $computer) 
   { $isLaptop = $true }
 $isLaptop
} 

　
　
if (Get-Laptop) {
    Write-Output "Computer is a laptop; will install VPN client..."

    if (Test-Path C:\Temp) {
        Write-Output "Temp folder found..."
        }
    else {
        Write-Output "Temp folder not found, creating Temp folder..."
        mkdir C:\Temp
        }

　
    Copy-Item '\\server\share\folder\vpnclient.exe' 'C:\Temp'
    Start-Process  'C:\Temp\vpnclient.exe' -Wait
    }
else {
    Write-Output "Computer is not a laptop, skipping VPN install..."
    } 

　
　
　
　
# Checks SCCM Software Center for available updates
$AvailableUpdates = Get-CimInstance -Namespace root\ccm\clientsdk -Query 'Select * from CCM_SoftwareUpdate'

　
Write-Output "$($AvailableUpdates.Count) Updates Pending..."

foreach ($update in $AvailableUpdates) {

    Switch ($AvailableUpdates.EvaluationState) {
        0 {Write-Error "ciJobStateNone";$errors++;break}
        1 {Write-Warning "ciJobStateAvailable";$errors++;break}
        2 {Write-Error "ciJobStateSubmitted";$errors++;break}
        3 {Write-Error "ciJobStateDetecting";$errors++;break}
        4 {Write-Error "ciJobStatePreDownload";$errors++;break}
        5 {Write-Error "ciJobStateDownloading";$errors++;break}
        6 {Write-Error "ciJobStateWaitInstall";$errors++;break}
        7 {Write-Error "ciJobStateInstalling";$errors++;break}
        8 {Write-Error "ciJobStatePendingSoftReboot";$errors++;break}
        9 {Write-Error "ciJobStatePendingHardReboot";$errors++;break}
        10 {Write-Error "ciJobStateWaitReboot";$errors++;break}
        11 {Write-Error "ciJobStateVerifying";$errors++;break}
        12 {Write-Output "ciJobStateInstallComplete";break}
        13 {Write-Error "ciJobStateError";$errors++;break}
        14 {Write-Error "ciJobStateWaitServiceWindow";$errors++;break}
        15 {Write-Error "ciJobStateWaitUserLogon";$errors++;break}
        16 {Write-Error "ciJobStateWaitUserLogoff";$errors++;break}
        17 {Write-Error "ciJobStateWaitJobUserLogon";$errors++;break}
        18 {Write-Error "ciJobStateWaitUserReconnect";$errors++;break}
        19 {Write-Error "ciJobStatePendingUserLogoff";$errors++;break}
        20 {Write-Error "ciJobStatePendingUpdate";$errors++;break}
        21 {Write-Error "ciJobStateWaitingRetry";$errors++;break}
        22 {Write-Error "ciJobStateWaitPresModeOff";$errors++;break}
        23 {Write-Error "ciJobStateWaitForOrchestration";$errors++;break}
        default {Write-Error "Install Status Unknown";$errors++;break}
    }
}

　
# check to see if the computer needs a reboot
if ((icim -namespace root\ccm\clientsdk -ClassName CCM_ClientUtilities -Name DetermineIfRebootPending).RebootPending) {
    Write-Output "Computer Requires Reboot from installed updates."
        5..1 | ForEach-Object {
        Write-Verbose "Restarting in $_ seconds..."
        Start-Sleep -Seconds 1
        Restart-Computer
        }
    }
    
    else {
    Write-Output "Updates are installed, no reboot necessary."
    }

　
　
　
# Installs McAfee Agent if not installed.
if (Test-Path "C:\Program Files\McAfee\Agent") {
    Write-Verbose "McAfee Agent is installed."
}
else {
    
    if (Test-Path 'C:\Temp') {
        Write-Verbose "Temp folder found..."
        }
    else {
        Write-Verbose "Temp folder not found, creating Temp folder..."
        mkdir 'C:\Temp'
        }
        
    Write-Verbose "McAfee Agent not installed. Installing McAfee Agent..."
    Copy-Item '\\server\share\folder\agent.exe' 'C:\Temp'
    Start-Process 'C:\Temp\agent.exe' -ArgumentList /install=agent, /s, /forceinstall -Wait
    Write-Output 'McAfee Agent installtion complete.'
}

　
function Is-Installed ($program) {
# Checks to see what applications are installed.
    
    $x86 = ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    $x64 = ((Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    return $x86 -or $x64;
}

　
　
　
$applist = @(
"McAfee Agent",
"Microsoft Office",
"McAfee Policy Auditor Agent",
"McAfee VirusScan Enterprise",
"Microsoft S/MIME"
 )

　
Write-Verbose "Checking for installed applications..."

foreach ($program in $applist) { 

　
    if (Is-Installed -program $program) {
        Write-Output "$program is installed."
        }
    else {
        Write-Error "$program NOT found!" -Category NotInstalled
        $errors++
    }

}

　
# Check BitLocker Status
# Win32_EncryptableVolume class at MSDN:
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa376483(v=vs.85).aspx

$BLStatus = Get-WmiObject -namespace root\CIMv2\Security\MicrosoftVolumeEncryption -class Win32_EncryptableVolume

Switch ($BLStatus.ConversionStatus) {
    0 {Write-Error "HDD is Fully Decrypted"; $errors++; break}
    1 {Write-Output "HDD is Fully Encrypted"; break}
    2 {Write-Warning "HDD Encryption is In Progress"; break}
    3 {Write-Error "HDD Decryption is In Progress"; $errors++; break}
    4 {Write-Error "HDD Encryption is Paused"; $errors++; break}
    5 {Write-Error "HDD Decryption is Paused"; $errors++; break}
    default {Write-Warning "Unknown BitLocker status!"; $errors++; break}
}

　
　
Write-Output "Script finished with $errors errors."

　
　
#  script results

if ($errors -eq "0") {Write-Output "[FINAL] The image has been validated successfully!"}

else {
    Write-Output -ForegroundColor Red "[FINAL] Image Validation Failed!"
    }

　
　
　
Stop-Transcript

　
　
　
        
