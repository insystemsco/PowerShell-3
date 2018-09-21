<#    
    .DESCRIPTION
    Gathers monitor serial numbers from networked computers.

    .NOTES
    
    Changelog:
        2018-08-30 - Version 0.1
            Initial working draft. 

#>
    
$ExportPath = "C:\temp\MonitorInventory.csv"

$Computers = Get-ADComputer -Filter * -SearchBase "OU=Computers,DC=karl,DC=lab"


    foreach ($computer in $Computers) {
        $ComputerName = $computer.Name

        Write-Output "Working on $ComputerName"

        if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {

            $MakeModel = Get-WmiObject -ComputerName $ComputerName WmiMonitorID -Namespace root\wmi |
            ForEach-Object {
               ($_.UserFriendlyName -notmatch 0 | ForEach-Object {[char]$_}) -join ""
           }

           $Monitor1Model = $MakeModel[0]
           $Monitor2Model = $MakeModel[1]
           $Monitor3Model = $MakeModel[2]
           $Monitor4Model = $MakeModel[3]



           $Serial = Get-WmiObject -ComputerName $ComputerName WmiMonitorID -Namespace root\wmi |
            ForEach-Object {
                ($_.SerialNumberID -notmatch 0 | ForEach-Object {[char]$_}) -join ""
            }

            $Monitor1Serial = $Serial[0]
            $Monitor2Serial = $Serial[1]
            $Monitor3Serial = $Serial[2]
            $Monitor4Serial = $Serial[3]



            $OutputObj  = New-Object -Type PSObject

            $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $ComputerName -ErrorAction Ignore
            $OutputObj | Add-Member -MemberType NoteProperty -Name Monitor1Model -Value $Monitor1Model -ErrorAction Ignore
            $OutputObj | Add-Member -MemberType NoteProperty -Name Monitor2Model -Value $Monitor2Model -ErrorAction Ignore
            $OutputObj | Add-Member -MemberType NoteProperty -Name Monitor3Model -Value $Monitor3Model -ErrorAction Ignore
            $OutputObj | Add-Member -MemberType NoteProperty -Name Monitor4Model -Value $Monitor4Model -ErrorAction Ignore
            $OutputObj | Add-Member -MemberType NoteProperty -Name Monitor1Serial -Value $Monitor1Serial -ErrorAction Ignore
            $OutputObj | Add-Member -MemberType NoteProperty -Name Monitor2Serial -Value $Monitor2Serial -ErrorAction Ignore
            $OutputObj | Add-Member -MemberType NoteProperty -Name Monitor3Serial -Value $Monitor3Serial -ErrorAction Ignore
            $OutputObj | Add-Member -MemberType NoteProperty -Name Monitor4Serial -Value $Monitor4Serial -ErrorAction Ignore
            $OutputObj | Add-Member -MemberType NoteProperty -Name Online -Value "YES" -ErrorAction Ignore

            $OutputObj | Export-Csv $ExportPath -Append -NoTypeInformation -ErrorAction Ignore -Force
        }

        else {
            $OutputObj  = New-Object -Type PSObject
            $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $ComputerName -ErrorAction Ignore
            $OutputObj | Add-Member -MemberType NoteProperty -Name Online -Value "NO" -ErrorAction Ignore
            $OutputObj | Export-Csv $ExportPath -Append -NoTypeInformation -ErrorAction Ignore -Force
        }

    }



