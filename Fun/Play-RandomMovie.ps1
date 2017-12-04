function Play-RandomMovie {
        
        <#
       .SYNOPSIS
           Plays a random movie from a folder (includes subfolders).
            
       .PARAMETER MoviePath
           The folder path which contains your movies.
       
       .EXAMPLE
           Play-RandomMovie -MoviePath 'C:\Movies'
    
       #>
        
       [CmdletBinding()]
       Param(
           [Parameter(Mandatory=$True)]
           [ValidateNotNullOrEmpty()]
           [string]$MoviePath
       )
    
Get-ChildItem -Path $MoviePath -File -Recurse |
Get-Random |
ForEach-Object {mpv $_.FullName --fullscreen}

}