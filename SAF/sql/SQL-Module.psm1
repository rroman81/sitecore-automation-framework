$ErrorActionPreference = "Stop"

# Private functions
function ImportSqlModule {
    if ($global:Configuration.offlineMode -eq $false) {
        if (Get-Module -Name SqlServer -ListAvailable) {
            Write-Warning "SqlServer module is installed. Updating..."
            Update-Module -Name SqlServer
        }
        else {
            Write-Output "Installing SqlServer module..."
            Install-Module -Name SqlServer -AllowClobber
        }
    }
    else {
        Write-Warning "SAF is running in offline mode. It assumes that you have installed SqlServer Powershell module latest version manually!"
        Start-Sleep -s 5
    }

    Get-Module -Name SqlServer | Remove-Module
    Import-Module -Name SqlServer
}

function DatabaseExists {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$DatabaseName,
        [string]$Username,
        [string]$Password
    )

    $exists = $false
    
    # Load the SMO assembly and create a Server object
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
    $server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $SqlServer
    
    # Set credentials
    $server.ConnectionContext.LoginSecure = $false
    $server.ConnectionContext.set_Login($Username)
    $securedPassword = ConvertTo-SecureString $Password -AsPlainText -Force
    $server.ConnectionContext.set_SecurePassword($securedPassword)

    foreach ($db in $server.databases) {  
        if ($db.name -eq $DatabaseName) {
            $exists = $true
        }
    }

    return $exists
}

function SqlLoginExists {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$SqlLogin
    )

    # Load the SMO assembly and create a Server object
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
    $server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $SqlServer
    
    if (($server.logins).Name -Contains $SqlLogin) {
        return $true
    }
    else {
        return $false
    }
}

function DeleteDb {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$DatabaseName,
        [string]$Username,
        [string]$Password
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

    if (!(DatabaseExists -SqlServer $SqlServer -DatabaseName $DatabaseName -Username $Username -Password $Password)) {
        Write-Warning "'$DatabaseName' doesn't exist. Skipping delete..."
    }
    else {
        Push-Location
        Write-Output "Deleting SQL Database '$DatabaseName'..."
        Invoke-Sqlcmd $cmd -QueryTimeout 3600 -ServerInstance $SqlServer -Username $Username -Password $Password
        Write-Output "Done."
        Pop-Location
    }
}

function LoadDacfx {
    $dacfxPath = "C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin\Microsoft.SqlServer.Dac.dll"

    if (-not (Test-Path $dacfxPath)) {
        throw "Microsoft.SqlServer.Dac.dll doesn't exist '$dacfxPath'"
    }

    Add-Type -Path $dacfxPath
}

function CreateDbUser {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$Username,
        [string]$Password,
        [string]$DbUser,
        [string]$DbPassword,
        [string]$DatabaseName
    )

    $cmd = 
    @"
Use [$DatabaseName]
Go
IF NOT EXISTS (SELECT name 
                FROM [sys].[database_principals]
                WHERE [type] = 'S' AND name = N'$DbUser')
BEGIN
ALTER DATABASE [$DatabaseName] 
SET CONTAINMENT = partial
CREATE USER [$DbUser] WITH PASSWORD = '$DbPassword';
EXEC sp_addrolemember 'db_datareader', [$DbUser];
EXEC sp_addrolemember 'db_datawriter', [$DbUser];
GRANT EXECUTE TO [$DbUser];
END
"@

    Write-Output "Creating database user '$DbUser' for '$DatabaseName' database..."
    Push-Location
    Invoke-Sqlcmd $cmd -QueryTimeout 3600 -ServerInstance $SqlServer -Username $Username -Password $Password
    Pop-Location
    Write-Output "Creating database user '$DbUser' done."
}

function SetDbOwner {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$SqlLogin,
        [string]$DatabaseName,
        [string]$Username,
        [string]$Password
    )

    if (!(DatabaseExists -SqlServer $SqlServer -DatabaseName $DatabaseName -Username $Username -Password $Password)) {
        Write-Warning "'$DatabaseName' doesn't exist. Skipping set db_owner..."
    }
    else {
        Write-Output "Setting db_owner = '$SqlLogin' for '$DatabaseName' database..."
        $server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") $SqlServer
        foreach ($db in $server.databases) {  
            if ($db.name -eq $DatabaseName) {
                Invoke-Sqlcmd -ServerInstance $SqlServer -Database $DatabaseName -Query "EXEC sp_changedbowner '$SqlLogin'"
            }
        }
        Write-Output "Setting db_owner = '$SqlLogin' for '$DatabaseName' database done."
    }
}

# Private functions

function EnableContainedDatabaseAuth {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$Username,
        [string]$Password
    )

    Write-Output "Enable contained database authentication started..."

    ImportSqlModule

    $cmd = 
    @"
sp_configure 'contained database authentication', 1; 
GO
RECONFIGURE; 
GO
"@

    Push-Location
    Invoke-Sqlcmd $cmd -QueryTimeout 3600 -ServerInstance $SqlServer -Username $Username -Password $Password
    Pop-Location

    Write-Output "Enable contained database authentication done."
}

function DeleteDatabases {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$Prefix,
        [string[]]$Databases,
        [string]$Username,
        [string]$Password
    )

    ImportSqlModule

    Write-Output "Delete existing databases started..."

    foreach ($db in $Databases) {
        $dbName = "$($Prefix)_$db"
        DeleteDb -SqlServer $SqlServer -DatabaseName $dbName -Username $Username -Password $Password
    }

    Write-Output "Delete existing databases done."

}

function DeleteLogin {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$SqlLogin,
        [string]$Username,
        [string]$Password
    )

    ImportSqlModule

    Write-Output "Delete SQL Login '$SqlLogin' started..."

    $cmd = 
    @"
USE [master]
GO
DROP LOGIN [$SqlLogin]
GO
"@

    if (!(SqlLoginExists -SqlServer $SqlServer -SqlLogin $SqlLogin)) {
        Write-Warning "'$SqlLogin' doesn't exist. Skipping delete..."
    }
    else {
        Push-Location
        Write-Output "Deleting SQL Login '$SqlLogin'..."
        Invoke-Sqlcmd $cmd -QueryTimeout 3600 -ServerInstance $SqlServer -Username $Username -Password $Password
        Write-Output "Done."
        Pop-Location
    }

    Write-Output "Delete SQL Login '$SqlLogin' done."
}

function DeployDacpac {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$Username,
        [string]$Password,
        [string]$LocalDbUsername,
        [string]$LocalDbPassword,
        [string]$Dacpac,
        [string]$TargetDatabaseName
    )

    ImportSqlModule

    if (DatabaseExists -SqlServer $SqlServer -DatabaseName $TargetDatabaseName -Username $Username -Password $Password) {
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
        Write-Output "Starting Dacpac deployment for '$TargetDatabaseName'..."
        $null = $dacServices.GenerateDeployScript($dacpackage, $TargetDatabaseName, $null)
        $null = $dacServices.Deploy($dacpackage, $TargetDatabaseName, $true, $null, $null)
        Write-Output "Dacpac deployed '$TargetDatabaseName' successfully."
    }

    CreateDbUser -SqlServer $SqlServer -Username $Username -Password $Password -DbUser $LocalDbUsername -DbPassword $LocalDbPassword -DatabaseName $TargetDatabaseName 
}

Export-ModuleMember -Function "DeleteDatabases"
Export-ModuleMember -Function "DeleteLogin"
Export-ModuleMember -Function "DeployDacpac"
Export-ModuleMember -Function "EnableContainedDatabaseAuth"