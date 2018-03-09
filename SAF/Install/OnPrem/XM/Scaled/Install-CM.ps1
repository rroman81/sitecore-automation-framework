Import-Module "$PSScriptRoot\..\..\..\..\SQL\SQL-Module.psm1" -Force
Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlUser = $global:Configuration.sql.adminUsername
$sqlAdminPassword = $global:Configuration.sql.adminPassword
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$solrUrl = $global:Configuration.search.solr.serviceUrl
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *cm.scwdp.zip*

$count = 1

foreach ($cm in $global:Configuration.sitecore) {
    $siteName = $cm.hostName
    $installDir = $cm.installDir
    $sslCert = $cm.sslCert

    Write-Output "Testing installation of Sitecore CM$count..."
    if (TestURI -Uri "https://$siteName") {
        Write-Output "Sitecore CM$count has been installed before. Going forward..."
    }
    else {
        Write-Output "Install Sitecore CM$count started..."

        $dbs = @("Core", "Master", "Web", "ExperienceForms")
        DeleteDatabases -SqlServer $sqlServer -Prefix $prefix -Databases $dbs -Username $sqlUser -Password $sqlAdminPassword

        $sitecoreParams = @{
            Path              = "$sourcePackageDirectory\sitecore-XM1-cm.json"
            Package           = $package.FullName
            LicenseFile       = $license
            SqlDbPrefix       = $prefix
            SqlServer         = $sqlServer
            SqlAdminUser      = $sqlUser
            SqlAdminPassword  = $sqlAdminPassword
            SqlCoreUser       = "$($prefix)_coreuser"
            SqlCorePassword   = $sqlSitecorePassword
            SqlMasterUser     = "$($prefix)_masteruser"
            SqlMasterPassword = $sqlSitecorePassword
            SqlWebUser        = "$($prefix)_webuser"
            SqlWebPassword    = $sqlSitecorePassword
            SqlFormsUser      = "$($prefix)_formsuser"
            SqlFormsPassword  = $sqlSitecorePassword
            SolrCorePrefix    = $prefix
            SolrUrl           = $solrUrl
            Sitename          = $siteName
            SSLCert           = $sslCert
            InstallDirectory  = $installDir
        }

        Install-SitecoreConfiguration @sitecoreParams

        Write-Output "Install Sitecore CM$count done."
    }

    $count = $count + 1
}