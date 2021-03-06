$ErrorActionPreference = "Stop"
. "$PSScriptRoot\..\SolrParams.ps1"

Write-Output "Deleting folders started..."

$dirs = @($SolrServiceDir)
foreach ($dir in $dirs) {
    if (Test-Path $dir) {
        Write-Output "Deleting '$dir'..."
        Remove-Item -Path $dir -Recurse -Force | Out-Null
    }
    else {
        Write-Warning "'$dir' doesn't exist..."
    }
}

Write-Output "Deleting folders done." 