. "$PSScriptRoot\..\..\..\InstallParams.ps1"
$ErrorActionPreference = "Stop"

Write-Output "Processing Sitecore installation package started..."

if (Test-Path $SAFInstallPackageDir) {
    Remove-Item $SAFInstallPackageDir -Recurse -Force | Out-Null
}
Expand-Archive -Path $global:Configuration.installPackage -DestinationPath "$SAFInstallPackageDir" -Force
$configFilesZip = Get-ChildItem -Path "$SAFInstallPackageDir\*" -Include *Configuration*
Expand-Archive -Path $configFilesZip.FullName -DestinationPath "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XP0.json" -Destination "$SAFInstallPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\xconnect-xp0.json" -Destination "$SAFInstallPackageDir" -Force

Write-Output "Processing Sitecore installation package done."