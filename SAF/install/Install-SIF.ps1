$ErrorActionPreference = "Stop"

Write-Host "Install Sitecore Installation Framework (SIF) started..."

$repositoryUrl = "https://sitecore.myget.org/F/sc-powershell/api/v2"
$repositoryName = "SitecoreGallery"

# Check to see whether that location is registered already
$existing = Get-PSRepository -Name $repositoryName -ErrorAction Ignore

# If not, register it
if ($existing -eq $null)
{
    Register-PSRepository -Name $repositoryName -SourceLocation $repositoryUrl -InstallationPolicy Trusted 
}

if (Get-Module -ListAvailable -Name "SitecoreInstallFramework") {
    Update-Module -Name "SitecoreInstallFramework"
}
else {
    Install-Module -Name "SitecoreInstallFramework"
}

Write-Host "Install Sitecore Installation Framework (SIF) done."