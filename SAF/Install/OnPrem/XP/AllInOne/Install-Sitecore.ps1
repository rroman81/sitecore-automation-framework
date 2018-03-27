Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\SSL\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Install Sitecore started..."

$prefix = $global:Configuration.prefix
$clientCert = BuildClientCertName -Prefix $prefix
$license = $global:Configuration.license
$siteName = $global:Configuration.sitecore.hostNames[0]
$xConnectHostName = $global:Configuration.xConnect.hostName
$sqlServer = $global:Configuration.sql.serverName
$sqlUser =  $global:Configuration.sql.adminUsername
$sqlAdminPassword =  $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$installDir = $global:Configuration.sitecore.installDir
$solrUrl = $global:Items.SolrServiceUrl
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *single.scwdp.zip*

$dbs = @("Core", "EXM.Master", "ExperienceForms", "Master", "Processing.Tasks", "Reporting", "Web")
DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword

$sitecoreParams = @{
    Path                           = "$sourcePackageDirectory\sitecore-XP0.json"
    Package                        = $package.FullName
    LicenseFile                    = $license
    SqlDbPrefix                    = $prefix
    SqlServer                      = $sqlServer
    SqlAdminUser                   = $sqlUser
    SqlAdminPassword               = $sqlAdminPassword
    SqlCoreUser                    = "$($prefix)_coreuser"
    SqlCorePassword                = $sqlSitecorePassword
    SqlMasterUser                  = "$($prefix)_masteruser"
    SqlMasterPassword              = $sqlSitecorePassword
    SqlWebUser                     = "$($prefix)_webuser"
    SqlWebPassword                 = $sqlSitecorePassword
    SqlReportingUser               = "$($prefix)_reportinguser"
    SqlReportingPassword           = $sqlSitecorePassword
    SqlProcessingPoolsUser         = "$($prefix)_processingpoolsuser"
    SqlProcessingPoolsPassword     = $sqlSitecorePassword
    SqlProcessingTasksUser         = "$($prefix)_processingtasksuser"
    SqlProcessingTasksPassword     = $sqlSitecorePassword
    SqlReferenceDataUser           = "$($prefix)_referencedatauser"
    SqlReferenceDataPassword       = $sqlSitecorePassword
    SqlMarketingAutomationUser     = "$($prefix)_marketingautomationuser"
    SqlMarketingAutomationPassword = $sqlSitecorePassword
    SqlFormsUser                   = "$($prefix)_formsuser"
    SqlFormsPassword               = $sqlSitecorePassword
    SqlExmMasterUser               = "$($prefix)_exmmasteruser"
    SqlExmMasterPassword           = $sqlSitecorePassword
    SqlMessagingUser               = "$($prefix)_messaginguser"
    SqlMessagingPassword           = $sqlSitecorePassword
    SolrCorePrefix                 = $prefix
    SolrUrl                        = $solrUrl
    XConnectCert                   = $clientCert
    Sitename                       = $siteName
    XConnectCollectionService      = "https://$xConnectHostName"
    InstallDirectory               = $installDir
}
Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install Sitecore done."