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
$sqlUserPassword =  $global:Configuration.sql.adminPassword
$installDir = $global:Configuration.sitecore.installDir
$solrUrl = $global:Items.SolrServiceUrl
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *single.scwdp.zip*

CleanInstalledSitecoreDbs -SqlServer $sqlServer -Prefix $prefix -Username $sqlUser -Password $sqlUserPassword

$sitecoreParams = @{
    Path                           = "$sourcePackageDirectory\sitecore-XP0.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    SqlDbPrefix                    = $prefix
    SqlServer                      = $sqlServer
    SqlAdminUser                   = $sqlUser
    SqlAdminPassword               = $sqlUserPassword
    SqlCorePassword                = $sqlUserPassword
    SqlMasterPassword              = $sqlUserPassword
    SqlWebPassword                 = $sqlUserPassword
    SqlReportingPassword           = $sqlUserPassword
    SqlProcessingPoolsPassword     = $sqlUserPassword
    SqlProcessingTasksPassword     = $sqlUserPassword
    SqlReferenceDataPassword       = $sqlUserPassword
    SqlMarketingAutomationPassword = $sqlUserPassword
    SqlFormsPassword               = $sqlUserPassword
    SqlExmMasterPassword           = $sqlUserPassword
    SqlMessagingPassword           = $sqlUserPassword
    SolrCorePrefix                 = $prefix
    SolrUrl                        = $solrUrl
    XConnectCert                   = $cert
    Sitename                       = $siteName
    XConnectCollectionService      = "https://$xConnectCollectionService"
    InstallDirectory               = $installDir
}
Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install Sitecore done."