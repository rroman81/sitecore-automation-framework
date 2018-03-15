$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$siteName = $global:Configuration.automationReporting.hostName
$sslCert = $global:Configuration.automationReporting.sslCert
if ([string]::IsNullOrEmpty($sslCert)) {
    $sslCert = $siteName
}
$xConnectSslCert = $global:Configuration.xConnect.sslCert
if ([string]::IsNullOrEmpty($xConnectSslCert)) {
    $xConnectSslCert = $siteName
}
$installDir = $global:Configuration.automationReporting.installDir
$environment = $global:Configuration.xConnect.environment
$logLevel = $global:Configuration.xConnect.logLevel
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *marketingautomationreporting.scwdp.zip*

Write-Output "Install xDB Automation Reporting started..."

$sitecoreParams = @{
    Path                           = "$sourcePackageDirectory\xconnect-xp1-MarketingAutomationReporting.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    Sitename                       = $siteName
    XConnectCert                   = $xConnectSslCert
    SSLCert                        = $sslCert
    SqlDbPrefix                    = $prefix
    SqlReferenceDataUser           = "$($prefix)_referencedatauser"
    SqlReferenceDataPassword       = $sqlSitecorePassword
    SqlMarketingAutomationUser     = "$($prefix)_marketingautomationuser"
    SqlMarketingAutomationPassword = $sqlSitecorePassword
    SqlServer                      = $sqlServer
    XConnectEnvironment            = $environment
    XConnectLogLevel               = $logLevel
    InstallDirectory               = $installDir
}

Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install xDB Automation Reporting done."