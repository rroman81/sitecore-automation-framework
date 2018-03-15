Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlUser = $global:Configuration.sql.adminUsername
$sqlAdminPassword = $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$siteName = $global:Configuration.automationOperations.hostName
$sslCert = $global:Configuration.automationOperations.sslCert
if ([string]::IsNullOrEmpty($sslCert)) {
    $sslCert = $siteName
}
$xConnectSslCert = $global:Configuration.xConnect.sslCert
if ([string]::IsNullOrEmpty($xConnectSslCert)) {
    $xConnectSslCert = $siteName
}
$installDir = $global:Configuration.automationOperations.installDir
$environment = $global:Configuration.xConnect.environment
$logLevel = $global:Configuration.xConnect.logLevel
$collectionService = $global:Configuration.xConnect.collectionService
$referenceDataService = $global:Configuration.xConnect.referenceDataService
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *marketingautomation.scwdp.zip*

Write-Output "Install xDB Automation Operations started..."

$services = @("marketingautomationservice")
DeleteServices -HostName $siteName -Services $services

$sitecoreParams = @{
    Path                           = "$sourcePackageDirectory\xconnect-xp1-MarketingAutomation.json"
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