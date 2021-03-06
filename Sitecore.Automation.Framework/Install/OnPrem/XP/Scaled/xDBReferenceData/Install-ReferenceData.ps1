. "$PSScriptRoot\..\..\..\..\InstallParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\..\Common\SSL\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$siteName = $global:Configuration.xDB.referenceDataHostName
$sslCert = $global:Configuration.xDB.sslCert
if ([string]::IsNullOrEmpty($sslCert)) {
    $sslCert = BuildServerCertName -Prefix $prefix
}
$xConnectSslCert = $global:Configuration.xConnect.sslCert
if ([string]::IsNullOrEmpty($xConnectSslCert)) {
    $xConnectSslCert = BuildClientCertName -Prefix $prefix
}
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlUser = $global:Configuration.sql.adminUsername
$sqlAdminPassword = $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$installDir = $global:Configuration.xDB.installDir
$environment = $global:Configuration.xConnect.environment
$logLevel = $global:Configuration.xConnect.logLevel
$package = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *referencedata.scwdp.zip*

Write-Output "Install xDB Reference Data started..."

$dbs = @("ReferenceData")
DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword

$sitecoreParams = @{
    Path                           = "$SAFInstallPackageDir\xconnect-xp1-ReferenceData.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    Sitename                       = $siteName
    XConnectCert                   = $xConnectSslCert
    SSLCert                        = $sslCert
    SqlDbPrefix                    = $prefix
    SqlAdminUser                   = $sqlUser
    SqlAdminPassword               = $sqlAdminPassword
    SqlReferenceDataUser           = "$($prefix)_referencedatauser"
    SqlReferenceDataPassword       = $sqlSitecorePassword
    SqlServer                      = $sqlServer
    XConnectEnvironment            = $environment
    XConnectLogLevel               = $logLevel
    InstallDirectory               = $installDir
}
Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install xDB Reference Data done."