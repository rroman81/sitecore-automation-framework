. "$PSScriptRoot\..\..\..\InstallParams.ps1"
Import-Module "$PSScriptRoot\..\..\..\..\Common\WebAdministration-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$license = $global:Configuration.license
$sqlServer = $global:Configuration.sql.serverName
$sqlSitecorePassword = $global:Configuration.sql.sitecorePassword
$solrURL = $global:Configuration.search.solr.serviceURL
$package = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *cd.scwdp.zip*

$count = 1

foreach ($cd in $global:Configuration.sitecore) {
    $hostNames = $cd.hostNames
    $siteName = $hostNames[0]
    $installDir = $cd.installDir

    Write-Output "Testing installation of Sitecore CD$count..."
    if (TestURI -Uri "https://$siteName") {
        Write-Output "Sitecore CD$count has been installed before. Going forward..."
    }
    else {
        Write-Output "Install Sitecore CD$count started..."

        $sitecoreParams = @{
            Path              = "$SAFInstallPackageDir\sitecore-XM1-cd.json"
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
            SolrUrl           = $solrURL
            Sitename          = $siteName
            InstallDirectory  = $installDir
        }
        Install-SitecoreConfiguration @sitecoreParams
        AddWebBindings -SiteName $siteName -HostNames $hostNames
        Write-Output "Install Sitecore CD$count done."
    }

    $count = $count + 1
}