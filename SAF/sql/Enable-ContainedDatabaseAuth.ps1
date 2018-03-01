$ErrorActionPreference = "Stop"

Write-Output "Enable contained database authentication started..."

$sqlServer = $global:Configuration.sql.serverName
$username = $global:Configuration.sql.adminUsername
$password = $global:Configuration.sql.adminPassword

Write-Warning $username
Write-Warning $password

$cmd = 
@"
sp_configure 'contained database authentication', 1; 
GO
RECONFIGURE; 
GO
"@

Push-Location
Invoke-Sqlcmd $cmd -QueryTimeout 3600 -ServerInstance $sqlServer -Username $username -Password $password
Pop-Location

Write-Output "Enable contained database authentication done."