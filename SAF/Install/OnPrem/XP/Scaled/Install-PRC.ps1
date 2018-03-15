Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlUser = $global:Configuration.sql.adminUsername
$sqlAdminPassword = $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$solrUrl = $global:Configuration.search.solr.serviceUrl
$collectionService = $global:Configuration.xConnect.collectionService
$siteName = $global:Configuration.processing.hostName
$sslCert = $global:Configuration.processing.sslCert
if ([string]::IsNullOrEmpty($sslCert)) {
    $sslCert = $siteName
}
$xConnectSslCert = $global:Configuration.xConnect.sslCert
if ([string]::IsNullOrEmpty($xConnectSslCert)) {
    $xConnectSslCert = $siteName
}
$installDir = $global:Configuration.processing.installDir
$reportingServiceApiKey = $global:Configuration.reporting.serviceApiKey
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *prc.scwdp.zip*

Write-Output "Install Sitecore Processing started..."

$dbs = @("Processing.Tasks")
DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword

$sitecoreParams = @{
    Path                       = "$sourcePackageDirectory\sitecore-XP1-prc.json"
    Package                    = $package.FullName
    LicenseFile                = $license
    XConnectCert               = $xConnectSslCert
    SSLCert                    = $sslCert
    SqlDbPrefix                = $prefix
    SolrCorePrefix             = $prefix
    Sitename                   = $siteName
    SqlServer                  = $sqlServer
    SqlAdminUser               = $sqlUser
    SqlAdminPassword           = $sqlAdminPassword
    SqlCoreUser                = "$($prefix)_coreuser"
    SqlCorePassword            = $sqlSitecorePassword
    SqlMasterUser              = "$($prefix)_masteruser"
    SqlMasterPassword          = $sqlSitecorePassword
    SqlWebUser                 = "$($prefix)_webuser"
    SqlWebPassword             = $sqlSitecorePassword
    SqlReportingUser           = "$($prefix)_reportinguser"
    SqlReportingPassword       = $sqlSitecorePassword
    SqlReferenceDataUser       = "$($prefix)_referencedatauser"
    SqlReferenceDataPassword   = $sqlSitecorePassword
    SqlProcessingPoolsUser     = "$($prefix)_processingpoolsuser"
    SqlProcessingPoolsPassword = $sqlSitecorePassword
    SqlProcessingTasksUser     = "$($prefix)_processingtasksuser"
    SqlProcessingTasksPassword = $sqlSitecorePassword
    SolrUrl                    = $solrUrl
    ReportingServiceApiKey     = $reportingServiceApiKey
    XConnectCollectionService  = $collectionService
    InstallDirectory           = $installDir
}

Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install Sitecore Processing done."