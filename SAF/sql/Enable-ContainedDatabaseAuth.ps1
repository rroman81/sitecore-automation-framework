$ErrorActionPreference = "Stop"

Write-Host "Enable contained database authentication started..."

$sqlServer = $global:Configuration.sql.serverName

$cmd = 
@"
sp_configure 'contained database authentication', 1; 
GO
RECONFIGURE; 
GO
"@

Push-Location
Invoke-Sqlcmd $cmd -QueryTimeout 3600 -ServerInstance $sqlServer
Pop-Location

Write-Host "Enable contained database authentication done."