Import-Module "$PSScriptRoot\Sql-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$sqlServer = $global:Configuration.sql.serverName
$username = $global:Configuration.sql.adminUsername
$password = $global:Configuration.sql.adminPassword

EnableContainedDatabaseAuth -SqlServer $sqlServer -Username $username -Password $password