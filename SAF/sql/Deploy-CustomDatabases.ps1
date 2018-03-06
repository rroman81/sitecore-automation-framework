Import-Module "$PSScriptRoot\Sql-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Add custom databases started..."

if (($global:Configuration.sql.customDatabases -eq $null) -or ($global:Configuration.sql.customDatabases.Count -lt 1)) {
    Write-Warning "No custom databases found."
}
else {

    $sqlServer = $global:Configuration.sql.serverName
    $sqlUser = $global:Configuration.sql.adminUsername
    $sqlAdminPassword = $global:Configuration.sql.adminPassword
    $sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
   

    foreach ($db in $global:Configuration.sql.customDatabases) {
        $dacpac = $db.dacpack
        $localDbUserName = $db.loginUsername
        $connStrName = $db.connectionStringName
        $dacpackName = [System.IO.Path]::GetFileNameWithoutExtension($db.dacpack)
        $targetDatabaseName = "$($global:Configuration.prefix)_$dacpackName"
        
        DeployDacpac -SqlServer $sqlServer -Username $sqlUser -Password $sqlAdminPassword -LocalDbUsername $localDbUserName -LocalDbPassword $sqlSitecorePassword -Dacpac $dacpac -TargetDatabaseName $targetDatabaseName
        foreach($sitecoreInstance in $global:Configuration.sitecore){
            $sitecoreInstallDir = $sitecoreInstance.installDir
            AddConnectionString -SqlServer $sqlServer -Database $targetDatabaseName -Username $localDbUserName -Password $sqlSitecorePassword -WebsiteRootDir $sitecoreInstallDir -ConnStringName $connStrName
        }
    }
}

Write-Output "Add custom databases done."
