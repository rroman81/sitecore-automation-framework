$ErrorActionPreference = "Stop"

Write-Output "WebDeploy configuration started..."
choco upgrade webdeploy
Write-Output "WebDeploy configuration done."