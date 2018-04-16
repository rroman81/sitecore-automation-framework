Import-Module "$PSScriptRoot\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Configure MSSQL Server dependencies started..."

taskkill /F /IM Ssms.exe

if ($global:Configuration.offlineMode -eq $false) {
    choco upgrade sql-server-management-studio --limitoutput
    RefreshEnvironment
    Write-Output "Configure MSSQL Server dependencies done."
}
else {
    Write-Warning "SAF is running in offline mode. It assumes that you have installed SSMS latest version manually!"
    Start-Sleep -s 5
}