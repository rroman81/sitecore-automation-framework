. "$PSScriptRoot\..\..\..\..\InstallParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\..\Common\SSL\SSL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\..\Common\WebAdministration-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlUser = $global:Configuration.sql.adminUsername
$sqlAdminPassword = $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$solrURL = $global:Configuration.search.solr.serviceURL
$processingServiceURL = $global:Configuration.processing.serviceURL
$reportingServiceURL = $global:Configuration.reporting.serviceURL
$reportingServiceApiKey = $global:Configuration.reporting.serviceApiKey
$xConnectCollectionSearchService = $global:Configuration.xConnect.collectionSearchService
$xConnectReferenceDataService = $global:Configuration.xDB.referenceDataService
$marketingAutomationOperationsService = $global:Configuration.xDB.automationOperationsService
$marketingAutomationReportingService = $global:Configuration.xDB.automationReportingService
$exmCryptographicKey = $global:Configuration.exm.cryptographicKey
$exmAuthenticationKey = $global:Configuration.exm.authenticationKey
$package = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *cm.scwdp.zip*

$count = 1

foreach ($cm in $global:Configuration.sitecore) {
    $hostNames = $cm.hostNames
    $siteName = $hostNames[0]
    $installDir = $cm.installDir

    $sslCert = $cm.sslCert
    if ([string]::IsNullOrEmpty($sslCert)) {
        $sslCert = BuildServerCertName -Prefix $prefix
    }
    $xConnectSslCert = $global:Configuration.xConnect.sslCert
    if ([string]::IsNullOrEmpty($xConnectSslCert)) {
        $xConnectSslCert = BuildClientCertName -Prefix $prefix
    }

    Write-Output "Testing installation of Sitecore CM$count..."
    if (TestURI -Uri "https://$siteName") {
        Write-Output "Sitecore CM$count has been installed before. Going forward..."
    }
    else {
        
        Write-Output "Install Sitecore CM$count started..."

        $dbs = @("Core", "Master", "Web", "ExperienceForms", "EXM.Master", "Reporting")
        DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword

        # "ExmEdsProvider": {
        #     "Type": "string",
        #     "DefaultValue": "CustomSMTP",
        #     "Description": "The default EDS provider to be used."
        # },

        $sitecoreParams = @{
            Path                                 = "$SAFInstallPackageDir\sitecore-XP1-cm.json"
            Package                              = $package.FullName
            LicenseFile                          = $license
            SqlDbPrefix                          = $prefix
            SqlServer                            = $sqlServer
            SqlAdminUser                         = $sqlUser
            SqlAdminPassword                     = $sqlAdminPassword
            SqlCoreUser                          = "$($prefix)_coreuser"
            SqlCorePassword                      = $sqlSitecorePassword
            SqlMasterUser                        = "$($prefix)_masteruser"
            SqlMasterPassword                    = $sqlSitecorePassword
            SqlWebUser                           = "$($prefix)_webuser"
            SqlWebPassword                       = $sqlSitecorePassword
            SqlFormsUser                         = "$($prefix)_formsuser"
            SqlFormsPassword                     = $sqlSitecorePassword
            SqlReportingUser                     = "$($prefix)_reportinguser"
            SqlReportingPassword                 = $sqlSitecorePassword
            SqlReferenceDataUser                 = "$($prefix)_referencedatauser"
            SqlReferenceDataPassword             = $sqlSitecorePassword
            SqlExmMasterUser                     = "$($prefix)_exmmasteruser"
            SqlExmMasterPassword                 = $sqlSitecorePassword
            SqlMessagingUser                     = "$($prefix)_messaginguser"
            SqlMessagingPassword                 = $sqlSitecorePassword
            SolrCorePrefix                       = $prefix
            SolrUrl                              = $solrURL
            Sitename                             = $siteName
            XConnectCert                         = $xConnectSslCert
            SSLCert                              = $sslCert
            ProcessingService                    = $processingServiceURL
            ReportingService                     = $reportingServiceURL
            ReportingServiceApiKey               = $reportingServiceApiKey
            XConnectCollectionSearchService      = $xConnectCollectionSearchService
            XConnectReferenceDataService         = $xConnectReferenceDataService
            MarketingAutomationOperationsService = $marketingAutomationOperationsService
            MarketingAutomationReportingService  = $marketingAutomationReportingService
            EXMCryptographicKey                  = $exmCryptographicKey
            EXMAuthenticationKey                 = $exmAuthenticationKey
            InstallDirectory                     = $installDir
        }
        Install-SitecoreConfiguration @sitecoreParams
        AddWebBindings -SiteName $siteName -HostNames $hostNames -SSLCert $sslCert -Secure
        Write-Output "Install Sitecore CM$count done."
    }

    $count = $count + 1
}