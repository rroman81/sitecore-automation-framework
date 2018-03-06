Import-Module "$PSScriptRoot\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "IIS URL Rewrite configuration started..."
choco upgrade urlrewrite --limitoutput
RefreshEnvironment
Write-Output "IIS URL Rewrite configuration done."