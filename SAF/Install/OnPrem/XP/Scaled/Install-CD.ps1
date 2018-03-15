Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$solrUrl = $global:Configuration.search.solr.serviceUrl
$xConnectSslCert = $global:Configuration.xConnect.sslCert
$xConnectCollectionService = $global:Configuration.xConnect.collectionService
$xConnectReferenceDataService = $global:Configuration.xConnect.referenceDataService
$marketingAutomationOperationsService = $global:Configuration.automationOperations.operationsService
$marketingAutomationReportingService = $global:Configuration.automationOperations.reportingService
$exmCryptographicKey = $global:Configuration.exm.cryptographicKey
$exmAuthenticationKey = $global:Configuration.exm.authenticationKey
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *cd.scwdp.zip*

$count = 1

foreach ($cd in $global:Configuration.sitecore) {
    $siteName = $cd.hostName
    $installDir = $cd.installDir

    Write-Output "Testing installation of Sitecore CD$count..."
    if (TestURI -Uri "https://$siteName") {
        Write-Output "Sitecore CD$count has been installed before. Going forward..."
    }
    else {
        Write-Output "Install Sitecore CD$count started..."

        $sitecoreParams = @{
            Path                                 = "$sourcePackageDirectory\sitecore-XP1-cd.json"
            Package                              = $package.FullName
            LicenseFile                          = $license
            SqlDbPrefix                          = $prefix
            SqlServer                            = $sqlServer
            SqlCoreUser                          = "$($prefix)_coreuser"
            SqlCorePassword                      = $sqlSitecorePassword
            SqlWebUser                           = "$($prefix)_webuser"
            SqlWebPassword                       = $sqlSitecorePassword
            SqlFormsUser                         = "$($prefix)_formsuser"
            SqlFormsPassword                     = $sqlSitecorePassword
            SqlExmMasterUser                     = "$($prefix)_exmmasteruser"
            SqlExmMasterPassword                 = $sqlSitecorePassword
            SqlMessagingUser                     = "$($prefix)_messaginguser"
            SqlMessagingPassword                 = $sqlSitecorePassword
            SolrCorePrefix                       = $prefix
            SolrUrl                              = $solrUrl
            Sitename                             = $siteName
            XConnectCert                         = $xConnectSslCert
            XConnectCollectionService            = $xConnectCollectionService
            XConnectReferenceDataService         = $xConnectReferenceDataService
            MarketingAutomationOperationsService = $marketingAutomationOperationsService
            MarketingAutomationReportingService  = $marketingAutomationReportingService
            EXMCryptographicKey                  = $exmCryptographicKey
            EXMAuthenticationKey                 = $exmAuthenticationKey
            InstallDirectory                     = $installDir
        }

        Install-SitecoreConfiguration @sitecoreParams

        Write-Output "Install Sitecore CD$count done."
    }

    $count = $count + 1
}