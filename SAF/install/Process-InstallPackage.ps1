$ErrorActionPreference = "Stop"

Write-Output "Processing Sitecore installation package started..."

$installPackageDir = $global:Items.SAFInstallPackageDir

Expand-Archive -Path $global:Configuration.installPackage -DestinationPath "$installPackageDir" -Force
$configFilesZip = Get-ChildItem -Path "$installPackageDir\*" -Include *Configuration*
Expand-Archive -Path $configFilesZip.FullName -DestinationPath "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\..\overrides\onPremAllInOne\sitecore-XP0.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\..\overrides\onPremAllInOne\xconnect-xp0.json" -Destination "$installPackageDir" -Force

Write-Output "Processing Sitecore installation package done."