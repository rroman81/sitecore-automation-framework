. "$PSScriptRoot\..\..\..\..\InstallParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\..\..\Common\SSL\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$siteName = $global:Configuration.xDB.automationOperationsHostName
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
$collectionService = $global:Configuration.xConnect.collectionService
$referenceDataService = $global:Configuration.xDB.referenceDataService
$package = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *marketingautomation.scwdp.zip*

Write-Output "Install xDB Automation Operations started..."

$sitecoreParams = @{
    Path                           = "$SAFInstallPackageDir\xconnect-xp1-MarketingAutomation.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    Sitename                       = $siteName
    XConnectCert                   = $xConnectSslCert
    SSLCert                        = $sslCert
    SqlDbPrefix                    = $prefix
    SqlAdminUser                   = $sqlUser
    SqlAdminPassword               = $sqlAdminPassword
    SqlCollectionUser              = "$($prefix)_collectionuser"
    SqlCollectionPassword          = $sqlSitecorePassword
    SqlProcessingPoolsUser         = "$($prefix)_processingpoolsuser"
    SqlProcessingPoolsPassword     = $sqlSitecorePassword
    SqlMarketingAutomationUser     = "$($prefix)_marketingautomationuser"
    SqlMarketingAutomationPassword = $sqlSitecorePassword
    SqlReferenceDataUser           = "$($prefix)_referencedatauser"
    SqlReferenceDataPassword       = $sqlSitecorePassword
    SqlMessagingUser               = "$($prefix)_messaginguser"
    SqlMessagingPassword           = $sqlSitecorePassword
    SqlServer                      = $sqlServer
    XConnectCollectionService      = $collectionService
    XConnectReferenceDataService   = $referenceDataService
    XConnectEnvironment            = $environment
    XConnectLogLevel               = $logLevel
    InstallDirectory               = $installDir
}
Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install xDB Automation Operations done."