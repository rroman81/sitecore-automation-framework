. "$PSScriptRoot\..\..\InstallParams.ps1"
$ErrorActionPreference = "Stop"

Write-Output "Processing Sitecore installation package started..."

if (Test-Path $SAFInstallPackageDir) {
    Remove-Item $SAFInstallPackageDir -Recurse -Force | Out-Null
}
Expand-Archive -Path $global:Configuration.solr.install.installPackage -DestinationPath "$SAFInstallPackageDir" -Force
$configFilesZip = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *Configuration*
if ($configFilesZip) {
    Expand-Archive -Path $configFilesZip.FullName -DestinationPath "$SAFInstallPackageDir" -Force
}

Write-Output "Processing Sitecore installation package done."