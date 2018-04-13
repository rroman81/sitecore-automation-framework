. "$PSScriptRoot\..\..\..\..\InstallParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\..\Common\SSL\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$siteName = $global:Configuration.xConnect.collectionHostName
$sslCert = $global:Configuration.xConnect.sslCert
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
$installDir = $global:Configuration.xConnect.installDir
$environment = $global:Configuration.xConnect.environment
$logLevel = $global:Configuration.xConnect.logLevel
$package = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *collection.scwdp.zip*

Write-Output "Install xConnect Collection started..."

$dbs = @("MarketingAutomation", "Messaging", "Processing.Pools", "Xdb.Collection.Shard0", "Xdb.Collection.Shard1", "Xdb.Collection.ShardMapManager")
DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword
DeleteLogin -SqlServer $sqlServer -SqlLogin "$($prefix)_collectionuser" -Username $sqlUser -Password $sqlAdminPassword

$sitecoreParams = @{
    Path                           = "$SAFInstallPackageDir\xconnect-xp1-collection.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    Sitename                       = $siteName
    XConnectCert                   = $xConnectSslCert
    SqlDbPrefix                    = $prefix
    SqlAdminUser                   = $sqlUser
    SqlAdminPassword               = $sqlAdminPassword
    SqlCollectionUser              = "$($prefix)_collectionuser"
    SqlCollectionPassword          = $sqlSitecorePassword
    SqlProcessingPoolsUser         = "$($prefix)_processingpoolsuser"
    SqlProcessingPoolsPassword     = $sqlSitecorePassword
    SqlMarketingAutomationUser     = "$($prefix)_marketingautomationuser"
    SqlMarketingAutomationPassword = $sqlSitecorePassword
    SqlMessagingUser               = "$($prefix)_messaginguser"
    SqlMessagingPassword           = $sqlSitecorePassword
    SqlServer                      = $sqlServer
    XConnectEnvironment            = $environment
    XConnectLogLevel               = $logLevel
    SSLCert                        = $sslCert
    InstallDirectory               = $installDir
}
Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install xConnect Collection done."