 #Requires -RunAsAdministrator 

<# 
   .DESCRIPTION 
     Validates and corrects deficiencies for Windows 10 AGM image. 
  
   .NOTES 
     Author: Carl Hill 
     Contact: carl.l.hill@outlook.com
     Date Updated: 24 July 2017

   .CHANGELOG
    2017-08-24
        Replaced google.com with karl.lab for ping test
        Replaced Write-Host with Write-Verbose/Error/Warning/Output
        Simplified Countdown mechanism
        Added BitLocker HDD encryption detection
        Added pending updates detection

  
#> 

$InformationPreference = "Continue"
$errors = 0
$logpath = "\\server\share\SCRIPTS\Image Validation\logs"
$date = Get-Date -Format yyyy-MM-dd_HHmmss
[string]$logfile =  "$($env:COMPUTERNAME) - $($date).txt"

　
　
　
　
Start-Transcript -Path $logpath\$logfile -Append

function pingtest {
# pings karl.lab to verify network functionality
    Write-Verbose "Testing network functionality..." -Verbose

    if (Test-Connection -Count 1 karl.lab) {Write-Output "Network connection to karl.lab is successful. `n"}

        else {
            Write-Warning "Network connection to karl.lab NOT successful! `n"}
}

pingtest

　
　
function Portal-Check {
# Checks to see if the Portal page is added into the Site to Zone settings, and adds them if they are not

Write-Verbose "Checking for Portal access..." -Verbose

　
$portalHKLM1 = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey" -Name "*.site1.karl.lab" -ErrorAction SilentlyContinue
$portalHKLM2 = Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey" -Name "*.site2.site1.karl.lab" -ErrorAction SilentlyContinue

    if ($portalHKLM1.'*.site1.karl.lab' -eq 1 -and $portalHKLM2.'*.site2.site1.karl.lab' -eq 1) {
        Write-Output "Portal page Site to Zone has been added to Local Group Policy."
    }

　
    else {
        Write-Warning "Portal page Site to Zone has NOT been added to Local Group Policy!"
        Write-Verbose "The Portal page will now be added to the Site to Zone Local Group Policy.."

        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey" -Name "*.site1.karl.lab" -PropertyType String -Value 1 -Verbose
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMapKey" -Name "*.site2.site1.karl.lab" -PropertyType String -Value 1 -Verbose

    }
}

Portal-Check

　
# Finds all applications that are available in Software Center and are not installed.
$Applications = Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_Application | Where-Object {$_.ResolvedState -eq "Available" -and $_.InstallState -eq "NotInstalled"}
 
function InstallAllCCMApps { 
# Installs all available applications from Software Center. 
         

    foreach ($Application in $Applications) {
     
        Write-Verbose "Installing $application.FullName from Software Center..." -Verbose
         
        $Args = @{EnforcePreference = [UINT32] 0
        Id = "$($Application.id)"
        IsMachineTarget = $Application.IsMachineTarget
        IsRebootIfNeeded = $False
        Priority = 'High'
        Revision = "$($Application.Revision)" }
 
        Invoke-CimMethod -Namespace "root\ccm\clientSDK" -ClassName CCM_Application -MethodName Install -Arguments $Args | Out-Null
    }

}

# Installs all SCCM Apps  if there are any available.
if ($Applications -eq $null) {
        Write-Output "No available applications to install from Software Center."
        }

else{
    Write-Verbose "Installing all available SCCM applications..." -Verbose
    InstallAllCCMApps

    240..1 | % {
    Write-Progress -Activity "Waiting for SCCM Applications to Install..." -SecondsRemaining $_
    Start-Sleep -Seconds 1
    }

    
}
 
 

# Checks SCCM Software Center for available updates
$AvailableUpdates = Get-CimInstance -Namespace root\ccm\clientsdk -Query 'Select * from CCM_SoftwareUpdate'

　
Write-Verbose "$($AvailableUpdates.Count) Updates Pending..." -Verbose

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

# tell the server to install anything that has a deadline set
# iwmi -namespace root\ccm\clientsdk -Class CCM_SoftwareUpdatesManager -name InstallUpdates([System.Management.ManagementObject[]](gwmi -namespace root\ccm\clientsdk -query 'Select * from CCM_SoftwareUpdate'))

# check to see if the computer needs a reboot
if ((icim -namespace root\ccm\clientsdk -ClassName CCM_ClientUtilities -Name DetermineIfRebootPending).RebootPending) {
    Write-Output "Computer Requires Reboot from installed updates."
        5..1 | ForEach-Object {
        Write-Verbose "Restarting in $_ seconds..." -Verbose
        Start-Sleep -Seconds 1
        Restart-Computer
        }
    }
    
    else {
    Write-Output "Updates are installed, no reboot necessary."
    }

　
# Invoke-CimMethod -Namespace root\ccm\clientsdk -ClassName CCM_SoftwareUpdatesManager -Name InstallUpdates

　
# Installs McAfee Agent if not installed.
$EPOpath = "\\eur\netlogon\EPO\McAfee Agent for WIN10"
if (Test-Path "C:\Program Files\McAfee\Agent") {}
else {
    Write-Verbose "Installing McAfee Agent..." -Verbose
    Start-Process -FilePath "$EPOpath\FramePkg.exe" -ArgumentList /install=agent, /s, /forceinstall -Wait
    Write-Output "McAfee Agent installtion complete."
}

　
function Is-Installed ($program) {
# Checks to see what applications are installed.
    
    $x86 = ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    $x64 = ((Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    return $x86 -or $x64;
}

　
$applist = Get-Content "\\server\share\SCRIPTS\Image Validation\apps.txt"

Write-Verbose "Checking for installed applications..." -Verbose

foreach ($program in $applist) { 
# Pulls applications list from apps.txt and if checks if it is installed.

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

　
function FinalMessage {
#  script results

if ($errors -eq "0") {Write-Host -ForegroundColor Green "[FINAL] The image has been validated successfully!"}

else {
    Write-Host -ForegroundColor Red "[FINAL] Image Validation Failed!"
    & notepad.exe $logpath\$logfile
    }
}

　
FinalMessage

Stop-Transcript

　
　
　
        
