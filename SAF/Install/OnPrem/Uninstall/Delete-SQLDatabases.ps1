Import-Module "$PSScriptRoot\..\..\..\SQL\SQL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sqlServer = $global:Configuration.sql.serverName
$sqlUser = $global:Configuration.sql.adminUsername
$sqlAdminPassword = $global:Configuration.sql.adminPassword

$dbs = @("Core", "EXM.Master", "ExperienceForms", "MarketingAutomation", "Master", "Messaging", "Processing.Pools", "Processing.Tasks", "ReferenceData", "Reporting", "Web", "Xdb.Collection.Shard0", "Xdb.Collection.Shard1", "Xdb.Collection.ShardMapManager")

if (($global:Configuration.sql.customDatabases -eq $null) -or ($global:Configuration.sql.customDatabases.Count -lt 1)) {
    Write-Warning "No custom databases to delete."
}
else {
    $prefix = $global:Configuration.prefix
    foreach ($db in $global:Configuration.sql.customDatabases) {
        $dacpack = $db.dacpack
        $dacpackName = [System.IO.Path]::GetFileNameWithoutExtension($dacpack)
        $dbs += "$dacpackName"
    }
}

DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword