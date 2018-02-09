$ErrorActionPreference = "Stop"

function Import-SqlModule {
    
    if (Get-Module -ListAvailable -Name "SqlServer") {
        Update-Module -Name "SqlServer"
    }
    else {
        Install-Module -Name "SqlServer" -AllowClobber
    }

    Import-Module SqlServer
}

function DeleteDb {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$DatabaseName
    )

    $cmd = 
    @"
IF DB_ID('$DatabaseName') IS NOT NULL
BEGIN
ALTER DATABASE [$DatabaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'$DatabaseName'
DROP DATABASE [$DatabaseName]
END
"@
    Push-Location
    Invoke-Sqlcmd $cmd -QueryTimeout 3600 -ServerInstance $SqlServer
    Pop-Location
}

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
        DeleteDb -SqlServer $SqlServer -DatabaseName $dbName
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
        DeleteDb -SqlServer $SqlServer -DatabaseName $dbName
    }

    Write-Host "Clean existing databases done."
}

function Get-SupportedSqlServerVersions {
    $sqlServerVersion = @("140", "130")
    return $sqlServerVersion
}

function LoadDacfx {
    $dacfxPath = $null
    $sqlServerVersions = Get-SupportedSqlServerVersions
    foreach ($version in $sqlServerVersions) {
        $tempDacfxPath = "C:\Program Files (x86)\Microsoft SQL Server\$version\DAC\bin\Microsoft.SqlServer.Dac.dll"
        if (Test-Path $tempDacfxPath) { 
            $dacfxPath = $tempDacfxPath
        }
    }

    if ($dacfxPath -eq $null) {
        throw "Microsoft.SqlServer.Dac.dll doesn't exist"
    }

    Add-Type -Path $dacfxPath
}

function DatabaseExists {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$DatabaseName
    )

    Import-SqlModule

    $exists = $false
    
    # Get reference to database instance
    $server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $SqlServer
   
    foreach ($db in $server.databases) {  
        if ($db.name -eq $DatabaseName) {
            $exists = $true
        }
    }

    return $exists
}

function SetDbOwner {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$Username,
        [string]$DatabaseName
    )

    if (!(DatabaseExists -SqlServer $SqlServer -DatabaseName $DatabaseName)) {
        Write-Warning "'$TargetDatabaseName' doesn't exist. Setting db_owner won't be executed."
    }
    else {
        Write-Host "Setting db_owner = '$Username' for '$DatabaseName' database..."
        $server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $SqlServer
        foreach ($db in $server.databases) {  
            if ($db.name -eq $DatabaseName) {
                Invoke-Sqlcmd -ServerInstance $SqlServer -Database $DatabaseName -Query "EXEC sp_changedbowner '$Username'"
            }
        }
        Write-Host "Setting db_owner = '$Username' for '$DatabaseName' database done."
    }
}

function CreateDbUser {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$Username,
        [string]$Password,
        [string]$DatabaseName
    )

    $cmd = 
    @"
Use [$DatabaseName]
Go
ALTER DATABASE [$DatabaseName] 
SET CONTAINMENT = partial
GO
CREATE USER [$Username] WITH PASSWORD = '$Password';
GO
EXEC sp_addrolemember 'db_datareader', [$Username];
EXEC sp_addrolemember 'db_datawriter', [$Username];
GO
GRANT EXECUTE TO [$Username];
GO 
"@

    Write-Host "Creating database user '$Username'..."
    Push-Location
    Invoke-Sqlcmd $cmd -QueryTimeout 3600 -ServerInstance $SqlServer
    Pop-Location
    Write-Host "Creating database user '$Username' done."
}

function DeployDacpac {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$Username,
        [string]$LocalDbUsername,
        [string]$Password,
        [string]$Dacpac,
        [string]$TargetDatabaseName
    )

    if (DatabaseExists -SqlServer $SqlServer -DatabaseName $TargetDatabaseName) {
        Write-Warning "'$TargetDatabaseName' database exists. Dacpac deployement won't be executed."
    }
    else {

        LoadDacfx

        # Load DacPackage
        $dacpackage = [Microsoft.SqlServer.Dac.DacPackage]::Load($Dacpac)
    
        # Setup DacServices
        $connectionString = "server=$SqlServer;User ID=$Username;Password=$Password;"
        $dacServices = New-Object Microsoft.SqlServer.Dac.DacServices $connectionString
    
        # Deploy package
        Write-Host "Starting Dacpac deployment for '$TargetDatabaseName'..."
        $null = $dacServices.GenerateDeployScript($dacpackage, $TargetDatabaseName, $null)
        $null = $dacServices.Deploy($dacpackage, $TargetDatabaseName, $true, $null, $null)
        Write-Host "Dacpac deployed '$TargetDatabaseName' successfully."

        CreateDbUser -SqlServer $SqlServer -Username $LocalDbUsername -Password $Password -DatabaseName $TargetDatabaseName 
    }
}

Export-ModuleMember -Function "CleanInstalledXConnectDbs"
Export-ModuleMember -Function "CleanInstalledSitecoreDbs"
Export-ModuleMember -Function "DeleteDb"
Export-ModuleMember -Function "DeployDacpac"