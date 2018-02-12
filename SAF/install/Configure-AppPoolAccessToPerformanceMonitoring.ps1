Import-Module "$PSScriptRoot\..\common\Utils-Module.psm1"
$ErrorActionPreference = "Stop"

Write-Host "Configure AppPool access to performance monitoring started..."

$groups = @("Performance Log Users", "Performance Monitor Users")
$appPool = $global:Configuration.sitecore.hostName

AddAppPoolUserToGroups -AppPool $appPool -Groups $groups

Write-Host "Configure AppPool access to performance monitoring done."