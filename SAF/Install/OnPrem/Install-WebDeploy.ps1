Import-Module "$PSScriptRoot\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "WebDeploy configuration started..."
if ($global:Configuration.offlineMode -eq $false) {
    choco upgrade webdeploy --limitoutput
    RefreshEnvironment
    Write-Output "WebDeploy configuration done."
}
else {
    Write-Warning "SAF is running in offline mode. It assumes that you have installed WebDeploy latest version manually!"
    Start-Sleep -s 5
}
