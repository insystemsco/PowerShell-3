$email = "carl.l.hill.ptc@mail.com"

$result = 0..($email.length - 1) | Where-Object {$email[$_] -eq "."}


function WithMI {
    $names = $email.split(".")
    $FirstName = $names[0] | ForEach-Object {(Get-Culture).TextInfo.ToTitleCase("$_")}
    $MI = $names[1] | ForEach-Object {(Get-Culture).TextInfo.ToTitleCase("$_")}
    $LastName = $names[2] -replace '[^a-zA-Z-]','' | ForEach-Object {(Get-Culture).TextInfo.ToTitleCase("$_")}
    $PTC = $names[3].ToUpper() -replace "@MAIL",''

    $FirstName
    $MI
    $LastName
    $PTC
}
function WithoutMI {
    $names = $email.split(".")
    $FirstName = $names[0] | ForEach-Object {(Get-Culture).TextInfo.ToTitleCase("$_")}
    $LastName = $names[1] -replace '[^a-zA-Z-]','' | ForEach-Object {(Get-Culture).TextInfo.ToTitleCase("$_")}
    $PTC = $names[2].ToUpper() -replace "@MAIL",''

    $FirstName
    $LastName
    $PTC
}



if ($result.Count -eq 4) {
    "Has MI"
    WithMI
}
elseif ($result.Count -eq 3) {
    "Does not have MI"
    WithoutMI
}
else {"errorz"}

