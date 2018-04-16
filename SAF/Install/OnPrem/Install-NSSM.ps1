Import-Module "$PSScriptRoot\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Configure Non-Sucking Service Manager started..."
if ($global:Configuration.offlineMode -eq $false) {
    choco upgrade nssm -y --limitoutput
    RefreshEnvironment
    Write-Output "Configure Non-Sucking Service Manager done."
}
else {
    Write-Warning "SAF is running in offline mode. It assumes that you have installed Non-Sucking Service Manager latest version manually!"
    Start-Sleep -s 5
}
