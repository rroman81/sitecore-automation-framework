$ErrorActionPreference = "Stop"

$solrRootDir = $global:Configuration.search.solr.installDir
$sitecoreRootDir = $global:Configuration.sitecore.installDir
$xConnectRootDir = $global:Configuration.xConnect.installDir

Write-Output "Deleting folders started..." 
$dirs = @("$solrRootDir", "$sitecoreRootDir", "$xConnectRootDir")
foreach ($dir in $dirs) {
    if (Test-Path $dir) {
        Write-Output "Deleting '$dir'..."
        Remove-Item -Path $dir -Recurse -Force | Out-Null
    }
}
Write-Output "Deleting folders done." 