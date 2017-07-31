
get-wmiobject -query "SELECT * FROM CCM_SoftwareUpdate" -namespace "ROOT\ccm\ClientSDK"

Inverse Conditional:
If (-Not (Test-Connection -ComputerName $Computer -Count 1 -Quiet)) {
    #Short Circuit
}


$countdown = {
    5..1 | % {
        Write-Host "waiting" $_ "seconds..."
        Start-Sleep -Seconds 1
    }
}

Start-Job -Name count5 -ScriptBlock $countdown | Out-Null
    Get-Job | ? {$_.State -eq 'Complete' -and $_.HasMoreData} | % {Receive-Job $_}

while((Get-Job -State Running).count){
    Get-Job | ? {$_.State -eq 'Complete' -and $_.HasMoreData} | % {Receive-Job $_}
    start-sleep -seconds 1
}

Wait-Job -Name count5
Write-Host "End of Job"


