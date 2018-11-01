. "$PSScriptRoot\..\..\..\InstallParams.ps1"
$ErrorActionPreference = "Stop"

Write-Output "Processing Sitecore installation package started..."

if (Test-Path $SAFInstallPackageDir) {
    Remove-Item $SAFInstallPackageDir -Recurse -Force | Out-Null
}

Expand-Archive -Path $global:Configuration.installPackage -DestinationPath "$SAFInstallPackageDir" -Force
$configFilesZip = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *Configuration*
Expand-Archive -Path $configFilesZip.FullName -DestinationPath "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XP1-cd.json" -Destination "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XP1-cm.json" -Destination "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XP1-prc.json" -Destination "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XP1-rep.json" -Destination "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp1-collection.json" -Destination "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp1-collectionsearch.json" -Destination "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp1-MarketingAutomation.json" -Destination "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp1-MarketingAutomationReporting.json" -Destination "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp1-ReferenceData.json" -Destination "$SAFInstallPackageDir" -Force

Write-Output "Processing Sitecore installation package done."