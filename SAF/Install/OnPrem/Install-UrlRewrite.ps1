Import-Module "$PSScriptRoot\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "IIS URL Rewrite configuration started..."

if ($global:Configuration.offlineMode -eq $false) {
    choco upgrade urlrewrite --limitoutput
    RefreshEnvironment
    Write-Output "IIS URL Rewrite configuration done."
}
else {
    Write-Warning "SAF is running in offline mode. It assumes that you have installed IIS URL Rewrite latest version manually!"
    Start-Sleep -s 5
}
