
function Invoke-ImageValidation {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [string]$ComputerName
    )



<# 
   .DESCRIPTION 
     Validates and corrects deficiencies for Windows image. 
  
   .NOTES 
     Author: Carl Hill 
     Contact: carl.l.hill@outlook.com
     
#> 

    $GroupMembership = Get-ADComputer $ComputerName -Properties memberof | Select-Object -ExpandProperty MemberOf

if (($GroupMembership -contains "CN=BADGROUP,DC=KARL,DC=LAB") -or ($GroupMembership -contains "CN=BADGROUP2,DC=EUR,DC=KARL,DC=LAB")) {
    Write-Error "Computer is in Bad Group!" -Category ResourceExists -RecommendedAction " Repair"
    break
    }
    else {
        Write-Output "Computer is not in Bad Group"
        }


    if (Test-Path \\$ComputerName\C$\Temp) {
        Write-Output "Temp folder found..."
        }
    else {
        Write-Output "Temp folder not found, creating Temp folder..."
        mkdir \\$ComputerName\C$\Temp
        }

Copy-Item $PSScriptRoot\image-validation.ps1 \\$ComputerName\C$\Temp -Force

psexec -s \\$ComputerName powershell.exe -command "C:\Temp\image-validation.ps1"

}
