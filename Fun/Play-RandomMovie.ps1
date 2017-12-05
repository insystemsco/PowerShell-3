function Play-RandomMovie {   
    [CmdletBinding()]

    $ExcludedFiletypes = @(
        '*.sub'
        '*.srt'
        '*.jpg'
        '*.png'
    )
    
    $MoviePaths = @(
        'C:\Movies'
        'C:\Documentaries'
        'C:\AnimatedFilms'
    )

    (Get-ChildItem -Path $MoviePaths -File -Exclude $ExcludedFiletypes -Recurse).FullName |
    Get-Random |
    ForEach-Object {mpv $_}

}