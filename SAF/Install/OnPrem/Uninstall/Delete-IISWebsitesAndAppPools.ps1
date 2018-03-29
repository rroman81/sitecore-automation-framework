Import-Module "$PSScriptRoot\..\..\..\Common\WebAdministration-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Deleting IIS Websites and AppPools started..."

$sitecoreSite = $global:Configuration.sitecore.hostNames[0]
$xConnectSite = $global:Configuration.xConnect.hostName
$sites = @("$sitecoreSite", "$xConnectSite")

foreach ($site in $sites) {
    DeleteIISWebsite -SiteName $site
    DeleteIISAppPool -AppPoolName $site
}

Write-Output "Deleting IIS Websites and AppPools done."

