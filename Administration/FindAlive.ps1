$comps = Get-ADComputer -filter * -SearchBase "OU=Computers,DC=karl,DC=lab"

 $results = foreach ($comp in $comps) {
     New-Object -Type PSObject -Property @{
     ComputerName = $comp.Name
     IPv4 = ((Test-Connection -ComputerName $comp.Name -Count 1).IPV4Address).IPAddressToString
    }
}

$results | Select-Object ComputerName,IPv4 | Export-Csv -Path C:\Temp\pingresults.csv -NoTypeInformation
