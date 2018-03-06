Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Install Sitecore started..."

$prefix = $global:Configuration.prefix
$license = $global:Configuration.license
$siteName = $global:Configuration.sitecore.hostName
$xConnectCollectionService = $global:Configuration.xConnect.hostName
$cert = $global:Items.XConnectCertName
$sqlServer = $global:Configuration.sql.serverName
$sqlUser =  $global:Configuration.sql.adminUsername
$sqlAdminPassword =  $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$installDir = $global:Configuration.sitecore.installDir
$solrUrl = $global:Items.SolrServiceUrl
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *single.scwdp.zip*

CleanInstalledSitecoreDbs -SqlServer $sqlServer -Prefix $prefix -Username $sqlUser -Password $sqlAdminPassword

$sitecoreParams = @{
    Path                           = "$sourcePackageDirectory\sitecore-XP0.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    SqlDbPrefix                    = $prefix
    SqlServer                      = $sqlServer
    SqlAdminUser                   = $sqlUser
    SqlAdminPassword               = $sqlAdminPassword
    SqlCorePassword                = $sqlSitecorePassword
    SqlMasterPassword              = $sqlSitecorePassword
    SqlWebPassword                 = $sqlSitecorePassword
    SqlReportingPassword           = $sqlSitecorePassword
    SqlProcessingPoolsPassword     = $sqlSitecorePassword
    SqlReferenceDataPassword       = $sqlSitecorePassword
    SqlMarketingAutomationPassword = $sqlSitecorePassword
    SqlFormsPassword               = $sqlSitecorePassword
    SqlExmMasterPassword           = $sqlSitecorePassword
    SqlMessagingPassword           = $sqlSitecorePassword
    SolrCorePrefix                 = $prefix
    SolrUrl                        = $solrUrl
    XConnectCert                   = $cert
    Sitename                       = $siteName
    XConnectCollectionService      = "https://$xConnectCollectionService"
    InstallDirectory               = $installDir
}
Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install Sitecore done."