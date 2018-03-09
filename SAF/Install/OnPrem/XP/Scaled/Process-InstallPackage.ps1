$ErrorActionPreference = "Stop"

Write-Output "Processing Sitecore installation package started..."

$installPackageDir = $global:Items.SAFInstallPackageDir
if (Test-Path $installPackageDir) {
    Remove-Item $installPackageDir -Recurse -Force | Out-Null
}
Expand-Archive -Path $global:Configuration.installPackage -DestinationPath "$installPackageDir" -Force
$configFilesZip = Get-ChildItem -Path "$installPackageDir\*" -Include *Configuration*
Expand-Archive -Path $configFilesZip.FullName -DestinationPath "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XP1-cd.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XP1-cm.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XP1-prc.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XP1-rep.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp1-collection.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp1-collectionsearch.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp1-MarketingAutomation.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp1-MarketingAutomationReporting.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp1-ReferenceData.json" -Destination "$installPackageDir" -Force


Write-Output "Processing Sitecore installation package done."