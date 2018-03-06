Import-Module "$PSScriptRoot\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "WebDeploy configuration started..."
choco upgrade webdeploy --limitoutput
RefreshEnvironment
Write-Output "WebDeploy configuration done."