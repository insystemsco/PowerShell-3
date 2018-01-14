function New-BulkComputerAccounts {
<#
.SYNOPSIS
Creates new computer accounts in bulk.

.DESCRIPTION
Creates new computer accounts in bulk that do not already exist and names them to fill the gaps in the sequence number.

.PARAMETER TeamCode
The 4-letter team code: "JEDI","SITH", or "LOLZ"

.PARAMETER ComputerTypeCode
The 2-letter computer type code: DK for desktops or LP for laptops.

.EXAMPLE
New-BulkKarlLabComputerAccounts -TeamCode JEDI -ComputerTypeCode LP -RequestedNumber 5

.NOTES
Created 14-1-2018
Contact: carl.l.hill@outlook.com
#>

        [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true,
            HelpMessage="Enter the 4-letter Team Code"
            )]
            [ValidateSet("JEDI","SITH","LOLZ")]
            [String]$TeamCode,

            [Parameter(Mandatory=$true,
            HelpMessage="Enter DK or LP for the 2-letter computer type code"
            )]
            [ValidateSet("LP","DK")]
            [String]$ComputerTypeCode,

            [Parameter(Mandatory=$true,
            HelpMessage="Enter a number of new computer accounts from 1 to 999"
            )]
            [ValidateRange(1,999)]
            [Int]$RequestedNumber
        )


BEGIN {
    # Converts $ComputerType and $Team to uppercase
    $ComputerType = $ComputerTypeCode.ToUpper()
    $Team = $TeamCode.ToUpper()

    switch ($Team) {
        "JEDI" { $Description = "KARLLAB JEDI KNGIHTS" }
        "SITH" { $Description = "KARLLAB SITH LORDS" }
        "LOLZ" { $Description = "KARLLAB ROFLCOPTER" }
        Default {}
    }
    
}

PROCESS {
    # Generates an arrary with all of the computers with $Team in the name
    $ExistingComputers = @(
        "JEDI001LP","JEDI002LP","JEDI004LP","JEDI005LP","JEDI007LP"
        "JEDI002DK","JEDI005DK","JEDI008DK","JEDI011DK","JEDI013DK"
        "SITH001DK","SITH004DK","SITH005DK","SITH008DK","SITH009DK"
        "SITH001LP","SITH002LP","SITH005LP","SITH006LP","SITH009LP"
        "LOLZ034DK","LOLZ010LP") |
         Where-Object {($_ -match $Team) -and ($_ -match $ComputerType)}
    # $ExistingComputers = Get-ADComputer -Filter * -SearchBase OU=Computers,OU=Testing,DC=KARL,DC=LAB | Where-Object {($_.Name -match $Team) -and ($_.Name -match $ComputerType)}


    # Replaces all the non-digits (\D+) with an empty value. This effectively strips all non-digits from each computername in $ExistingComputers
    $ExistingComputerNumbers = $ExistingComputers -replace '\D+',''
    #$ExistingComputerNumbers = $ExistingComputers.Name -replace '\D+',''


    # Generates an array with all of the numberical possibilites for a computername and converts it to a 3-digit number
    $possibles = 1..999 | ForEach-Object {$_.ToString("000")}

    # Finds the difference of the $ExistingComputerNumbers and $possibles
    $difference = Compare-Object $ExistingComputerNumbers $possibles | Where-Object {$_.SideIndicator -eq '=>'} | ForEach-Object {$_.InputObject}

    # selects the first $RequestedNumber of objects from the difference and creates the computer account
    $difference | Select-Object -First $RequestedNumber | ForEach-Object {
        Write-Output "Creating $($Team)$($_)$ComputerType with description $Description"
        # New-ADComputer -Name "$($Team)$($_)$ComputerType" -Description $Description -Path "OU=Computers,OU=Testing,DC=KARL,DC=LAB"
    }
}

END{}

}