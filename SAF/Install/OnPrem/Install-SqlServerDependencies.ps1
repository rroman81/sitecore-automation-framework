Import-Module "$PSScriptRoot\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Install MSSQL Server dependencies started..."

taskkill /F /IM Ssms.exe 2> $null
choco upgrade sql-server-management-studio --limitoutput
RefreshEnvironment

Write-Output "Install MSSQL Server dependencies done."