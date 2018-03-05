[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$ExportPath,

    [Parameter()]
    [string]$ExportFile = "KarlsNASmedia.xlsx"
)

$MoviesLocation = "Z:\Movies"
$TvShowsLocation = "Z:\TV Shows"
$DocsLocation = "Z:\Documentaries\Films"
$DocuSeriesLocation = "Z:\Documentaries\Shows"


#### Documentaries

Write-Output "Gathering Documentaries..."

$Docs = Get-ChildItem $DocsLocation
$DocsOutput = foreach ($doc in $Docs) {
    New-Object -Type PSObject -Property @{
        Transfer = ""
        Title = (($doc.Name -split '\(\d\d\d\d\).*')[0]).Trim()
        Year = ($doc.Name -split '(\d\d\d\d)')[1]
    } 
}


#### Documentary Series

Write-Output "Gathering DocuSeries..."

$DocuSeries = Get-ChildItem $DocuSeriesLocation -Directory
$DocuSeriesOutput = foreach ($series in $DocuSeries) {
    New-Object -Type PSObject -Property @{
    Transfer = ""
    Title = $series.Name
    }
}


#### TV Shows

Write-Output "Gathering TV Shows..."

$TvShows = Get-ChildItem $TvShowsLocation -Directory
$TvShowsOutput = foreach ($show in $TvShows) {
    New-Object -Type PSObject -Property @{
    Transfer = ""
    Title = $show.Name
    Seasons = ((Get-ChildItem $show.FullName -Recurse -Directory | Where-Object {$_.Name -ne "Specials"} | Measure-Object).Count | Where-Object {$_ -ne 0})
    }
} 


#### Movies

Write-Output "Gathering Movies..."

$Movies = Get-ChildItem $MoviesLocation -Recurse -File
$MoviesOutput = foreach ($movie in $Movies) {
    New-Object -Type PSObject -Property @{
        Transfer = ""
        Title = (($movie.Name -split '\(\d\d\d\d\).*')[0]).Trim()
        Year = ($movie.Name -split '(\d\d\d\d)')[1]
        Collection = (($movie.Directory).Name | Where-Object {$_ -ne "Movies"})
    }
}


#### Formatting
Write-Output "Formatting Spreadsheet..."


$DocsSheet = $DocsOutput | Select-Object Transfer,Title,Year |
Export-Excel -Path $ExportPath\$ExportFile -WorkSheetname "Docs" -FreezeTopRow -BoldTopRow -TableName DocsTable -TableStyle Medium8 -AutoSize -PassThru

$DocsSheetObj = $DocsSheet.Workbook.Worksheets["Docs"]
foreach ($c in 1..3) {$DocsSheetObj.Column($c) | Set-Format -HorizontalAlignment Left}
Export-Excel -ExcelPackage $DocsSheet -WorkSheetname "Docs"



$DocuSeriesSheet = $DocuSeriesOutput | Select-Object Transfer,Title |
Export-Excel -Path $ExportPath\$ExportFile -WorkSheetname "DocuSeries" -FreezeTopRow -BoldTopRow -TableName DocuSeriesTable -TableStyle Medium8 -AutoSize -PassThru

$DocuSeriesSheetObj = $DocuSeriesSheet.Workbook.Worksheets["DocuSeries"]
foreach ($c in 1..2) {$DocuSeriesSheetObj.Column($c) | Set-Format -HorizontalAlignment Left}
Export-Excel -ExcelPackage $DocuSeriesSheet -WorkSheetname "DocuSeries"



$TvShowsSheet = $TvShowsOutput| Select-Object Transfer,Title,Seasons |
Export-Excel -Path $ExportPath\$ExportFile -WorkSheetname "TVshows" -FreezeTopRow -BoldTopRow -TableName TvShowsTable -TableStyle Medium8 -AutoSize -PassThru

$TvShowsSheetObj = $TvShowsSheet.Workbook.Worksheets["TVshows"]
foreach ($c in 1..3) {$TvShowsSheetObj.Column($c) | Set-Format -HorizontalAlignment Left}
Export-Excel -ExcelPackage $TvShowsSheet -WorkSheetname "TVshows"



$MoviesSheet = $MoviesOutput | Select-Object Transfer,Title,Year,Collection |
Export-Excel -Path $ExportPath\$ExportFile -WorkSheetname "Movies" -FreezeTopRow -BoldTopRow -TableName MoviesTable -TableStyle Medium8 -AutoSize -PassThru

$MoviesSheetObj = $MoviesSheet.Workbook.Worksheets["Movies"]
foreach ($c in 1..4) {$MoviesSheetObj.Column($c) | Set-Format -HorizontalAlignment Left}
Export-Excel -ExcelPackage $MoviesSheet -WorkSheetname "Movies"





Write-Output "Complete!"
