
function Add-RemoteRegKey {
    
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$ComputerName
)



$BaseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine","$ComputerName")

$SubKey = $BaseKey.OpenSubKey("Software\PATHTOREGKEY",$true)



# Create/Modify REG_SZ registry key type ^

$ValueName = "ValueName"
$ValueData = "ValueData"
$SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::String)


# Create/Modify REG_EXPAND_SZ registry key type ^
# 
# $ValueName = "MyExpandStringValue1"
# $ValueData = "%appdata%"
# $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::ExpandString)

# Create/Modify REG_MULTI_SZ registry key type ^
# 
# $ValueName = "MyMultiStringValue1"
# [string[]]$ValueData = ("test1","test2")
# $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::MultiString)

# Create/Modify DWORD registry key type ^
# 
# $ValueName = "MyDwordValue1"
# $ValueData = 123
# $SubKey.SetValue($ValueName, $ValueData, [Microsoft.Win32.RegistryValueKind]::DWORD)



Invoke-GPUdate -Computer $ComputerName


}