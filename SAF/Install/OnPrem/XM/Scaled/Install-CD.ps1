Import-Module "$PSScriptRoot\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$sourcePackageDirectory = $global:Items.SAFInstallPackageDir
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$solrUrl = $global:Configuration.search.solr.serviceUrl
$package = Get-ChildItem -Path "$sourcePackageDirectory\*" -Include *cd.scwdp.zip*

$count = 1

foreach ($cd in $global:Configuration.sitecore) {
    $siteName = $cd.hostNames[0]
    $installDir = $cd.installDir

    Write-Output "Testing installation of Sitecore CD$count..."
    if (TestURI -Uri "https://$siteName") {
        Write-Output "Sitecore CD$count has been installed before. Going forward..."
    }
    else {
        Write-Output "Install Sitecore CD$count started..."

        $sitecoreParams = @{
            Path              = "$sourcePackageDirectory\sitecore-XM1-cd.json"
            Package           = $package.FullName
            LicenseFile       = $license
            SqlDbPrefix       = $prefix
            SqlServer         = $sqlServer
            SqlCoreUser       = "$($prefix)_coreuser"
            SqlCorePassword   = $sqlSitecorePassword
            SqlWebUser        = "$($prefix)_webuser"
            SqlWebPassword    = $sqlSitecorePassword
            SqlFormsUser      = "$($prefix)_formsuser"
            SqlFormsPassword  = $sqlSitecorePassword
            SolrCorePrefix    = $prefix
            SolrUrl           = $solrUrl
            Sitename          = $siteName
            InstallDirectory  = $installDir
        }

        Install-SitecoreConfiguration @sitecoreParams

        Write-Output "Install Sitecore CD$count done."
    }

    $count = $count + 1
}