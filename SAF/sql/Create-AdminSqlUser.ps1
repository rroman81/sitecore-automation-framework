$ErrorActionPreference = "Stop"

Write-Host "Create SQL user started..."

$sqlServer = $global:Configuration.sql.serverName
$sqlUser = $global:Configuration.sql.username
$sqlUserPassword = $global:Configuration.sql.password

$createUserCMD = @"
IF NOT EXISTS 
    (SELECT name  
     FROM master.sys.server_principals
     WHERE name = '$sqlUser')
BEGIN
    CREATE LOGIN [$sqlUser] WITH PASSWORD = '$sqlUserPassword',  CHECK_POLICY= OFF
	exec sp_addsrvrolemember @loginame='$sqlUser', @rolename='sysadmin'
	SELECT 'user created on sql instance' [status]
	END
ELSE
	BEGIN
	SELECT 'user exists on sql instance' [status]
	END
"@

$workingDir = Get-Location
$createUserResult = Invoke-Sqlcmd -ServerInstance $sqlServer -Query $createUserCMD -QueryTimeout 3600
Set-Location $workingDir

$status = $createUserResult.status
Write-Host "$status"

Write-Host "Create SQL user done."