

function WithMI {
    $names = $email.split(".")
    $FirstName = $names[0] | ForEach-Object {(Get-Culture).TextInfo.ToTitleCase("$_")}
    $MI = $names[1] | ForEach-Object {(Get-Culture).TextInfo.ToTitleCase("$_")}
    $LastName = $names[2] -replace '[^a-zA-Z-]','' | ForEach-Object {(Get-Culture).TextInfo.ToTitleCase("$_")}
    $PTC = $names[3].ToUpper()

    $FirstName
    $MI
    $LastName
    $PTC
}
function WithoutMI {
    $names = $email.split(".")
    $FirstName = $names[0] | ForEach-Object {(Get-Culture).TextInfo.ToTitleCase("$_")}
    $LastName = $names[1] -replace '[^a-zA-Z-]','' | ForEach-Object {(Get-Culture).TextInfo.ToTitleCase("$_")}
    $PTC = $names[2].ToUpper()

    $FirstName
    $LastName
    $PTC
}


$email = Read-Host "Email address?"

$result = 0..($email.length - 1) | Where-Object {$email[$_] -eq "."}



if ($result.Count -eq 3) {
    "New user has MI"
    WithMI
}
elseif ($result.Count -eq 2) {
    "New user does not have MI"
    WithoutMI
}
else {"errorz"}

