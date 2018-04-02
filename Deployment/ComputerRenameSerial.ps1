$ComputerName = @()
$SerialNumber = @()

$CSV = "C:\Temp\lookup.csv"

Import-Csv $CSV |
    ForEach-Object {
        $ComputerName += $_.ComputerName
        $SerialNumber += $_.SerialNumber
    }


# Gets the serial number of the computer
$ComputerSerial = Get-WmiObject win32_bios | Select-Object SerialNumber -ExpandProperty SerialNumber



$MDTCreds = New-Object System.Management.Automation.PSCredential($username,$password)


if ($SerialNumber -contains $ComputerSerial)
    {
    $Where = [array]::IndexOf($SerialNumber, $ComputerSerial)
    Rename-Computer -NewName "$ComputerName[$Where]" -DomainCredential $MDTCreds -Restart
    Write-Host $ComputerName[$Where]
    }
