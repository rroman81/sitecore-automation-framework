$ErrorActionPreference = "Stop"

Write-Output "Processing Sitecore installation package started..."

$installPackageDir = $global:Items.SAFInstallPackageDir
if (Test-Path $installPackageDir) {
    Remove-Item $installPackageDir -Recurse -Force | Out-Null
}
Expand-Archive -Path $global:Configuration.installPackage -DestinationPath "$installPackageDir" -Force
$configFilesZip = Get-ChildItem -Path "$installPackageDir\*" -Include *Configuration*
Expand-Archive -Path $configFilesZip.FullName -DestinationPath "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XM1-cd.json" -Destination "$installPackageDir" -Force
Copy-Item "$PSScriptRoot\Overrides\sitecore-XM1-cm.json" -Destination "$installPackageDir" -Force

Write-Output "Processing Sitecore installation package done."