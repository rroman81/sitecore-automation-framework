$ErrorActionPreference = "Stop"

Write-Output "Processing Sitecore installation package started..."

$installPackageDir = $global:Items.SAFInstallPackageDir

Expand-Archive -Path $global:Configuration.installPackage -DestinationPath "$installPackageDir" -Force
$configFilesZip = Get-ChildItem -Path "$installPackageDir\*" -Include *Configuration*
Expand-Archive -Path $configFilesZip.FullName -DestinationPath "$installPackageDir" -Force

Write-Output "Processing Sitecore installation package done."