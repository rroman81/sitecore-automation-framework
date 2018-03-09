Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$siteName = $global:Configuration.collectionSearch.hostName
$installDir = $global:Configuration.collectionSearch.installDir
$xConnectSslCert = $global:Configuration.xConnect.sslCert
if ([string]::IsNullOrEmpty($xConnectSslCert)) {
    $xConnectSslCert = $global:Items.XConnectCertName
}
$sslCert = $global:Configuration.collectionSearch.sslCert
$environment = $global:Configuration.xConnect.environment
$logLevel = $global:Configuration.xConnect.logLevel
$solrUrl = $global:Configuration.search.solr.serviceUrl
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *collectionsearch.scwdp.zip*

Write-Output "Install xConnect Collection Search started..."

$services = @("IndexWorker")
DeleteServices -HostName $siteName -Services $services

$sitecoreParams = @{
    Path                           = "$sourcePackageDirectory\xconnect-xp1-collectionsearch.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    Sitename                       = $siteName
    XConnectCert                   = $xConnectSslCert
    SSLCert                        = $sslCert
    SqlDbPrefix                    = $prefix
    SolrCorePrefix                 = $prefix
    SqlCollectionUser              = "$($prefix)_collectionuser"
    SqlCollectionPassword          = $sqlSitecorePassword
    SqlProcessingPoolsUser         = "$($prefix)_processingpoolsuser"
    SqlProcessingPoolsPassword     = $sqlSitecorePassword
    SqlMarketingAutomationUser     = "$($prefix)_marketingautomationuser"
    SqlMarketingAutomationPassword = $sqlSitecorePassword
    SqlMessagingUser               = "$($prefix)_messaginguser"
    SqlMessagingPassword           = $sqlSitecorePassword
    SqlServer                      = $sqlServer
    SolrUrl                        = $solrUrl
    XConnectEnvironment            = $environment
    XConnectLogLevel               = $logLevel
    InstallDirectory               = $installDir
}

Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install xConnect Collection Search done."