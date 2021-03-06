. "$PSScriptRoot\..\..\..\..\InstallParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\..\Common\SSL\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$siteName = $global:Configuration.processing.hostName
$sslCert = $global:Configuration.processing.sslCert
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
$solrURL = $global:Configuration.search.solr.serviceURL
$collectionService = $global:Configuration.xConnect.collectionService
$installDir = $global:Configuration.processing.installDir
$reportingServiceApiKey = $global:Configuration.reporting.serviceApiKey
$package = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *prc.scwdp.zip*

Write-Output "Install Sitecore Processing started..."

$dbs = @("Processing.Tasks")
DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword

$sitecoreParams = @{
    Path                       = "$SAFInstallPackageDir\sitecore-XP1-prc.json"
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
    SolrUrl                    = $solrURL
    ReportingServiceApiKey     = $reportingServiceApiKey
    XConnectCollectionService  = $collectionService
    InstallDirectory           = $installDir
}

Install-SitecoreConfiguration @sitecoreParams

Write-Output "Install Sitecore Processing done."