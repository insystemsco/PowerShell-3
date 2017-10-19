## https://blogs.technet.microsoft.com/heyscriptingguy/2013/06/03/generating-a-new-password-with-windows-powershell/

$ascii=$NULL;For ($a=33;$a –le 126;$a++) {$ascii+=,[char][byte]$a }

Function GET-Temppassword() {
    Param(
    [int]$length=10,
    [string[]]$sourcedata
    )
    
    For ($loop=1; $loop –le $length; $loop++) {
                $TempPassword+=($sourcedata | GET-RANDOM)
                }
    return $TempPassword
    }



