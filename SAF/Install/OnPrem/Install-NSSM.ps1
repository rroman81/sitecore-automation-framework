Import-Module "$PSScriptRoot\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Install Non-Sucking Service Manager started..."
choco upgrade nssm -y --limitoutput
RefreshEnvironment
Write-Output "Install Non-Sucking Service Manager done."