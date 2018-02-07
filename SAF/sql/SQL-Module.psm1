$ErrorActionPreference = "Stop"

function CleanInstalledXConnectDbs {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$Prefix
    )

    $dbs = @("MarketingAutomation", "Messaging", "Processing.Pools", "ReferenceData")

    Write-Host "Clean existing databases started..."

    foreach ($db in $dbs) {
        $dbName = "$($Prefix)_$db"
        $cmd = 
@"
IF DB_ID('$dbName') IS NOT NULL
BEGIN
    ALTER DATABASE [$dbName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'$dbName'
    DROP DATABASE [$dbName]
END
"@
        $workingDir = Get-Location
        Invoke-Sqlcmd $cmd -QueryTimeout 3600 -ServerInstance $SqlServer
        Set-Location $workingDir
    }

     Write-Host "Clean existing databases done."
}

function CleanInstalledSitecoreDbs {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$Prefix
    )

    $dbs = @("EXM.Master", "ExperienceForms", "Master", "Processing.Tasks", "Reporting", "Web", "Xdb.Collection.Shard0", "Xdb.Collection.Shard1", "Xdb.Collection.ShardMapManager")

    Write-Host "Clean existing databases started..."

    foreach ($db in $dbs) {
        $dbName = "$($Prefix)_$db"
        $cmd = 
@"
IF DB_ID('$dbName') IS NOT NULL
BEGIN
    ALTER DATABASE [$dbName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'$dbName'
    DROP DATABASE [$dbName]
END
"@
        $workingDir = Get-Location
        Invoke-Sqlcmd $cmd -QueryTimeout 3600 -ServerInstance $SqlServer
        Set-Location $workingDir
    }

     Write-Host "Clean existing databases done."
}

Export-ModuleMember -Function "CleanInstalledXConnectDbs"
Export-ModuleMember -Function "CleanInstalledSitecoreDbs"