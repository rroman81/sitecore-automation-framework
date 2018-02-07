$ErrorActionPreference = "Stop"

Write-Host "Processing Sitecore installation package started..."

$installPackageDir = "$PSScriptRoot\..\temp\package"
$global:Items.Add("SAFInstallPackageDir", $installPackageDir)

Expand-Archive -Path $global:Configuration.installPackage -DestinationPath "$installPackageDir" -Force
$configFilesZip = Get-ChildItem -Path "$installPackageDir\*" -Include *Configuration*
Expand-Archive -Path $configFilesZip.FullName -DestinationPath "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\..\overrides\onPremAllInOne\sitecore-XP0.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\..\overrides\onPremAllInOne\xconnect-xp0.json" -Destination "$installPackageDir" -Force

Write-Host "Processing Sitecore installation package done."