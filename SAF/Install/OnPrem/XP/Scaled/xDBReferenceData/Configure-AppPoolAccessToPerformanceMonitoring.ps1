Import-Module "$PSScriptRoot\..\..\..\..\..\Common\WebAdministration-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Configure AppPool access to performance monitoring started..."

$groups = @("Performance Log Users", "Performance Monitor Users")

$pools = @()
$pools += $global:Configuration.xDB.referenceDataHostName

AddAppPoolUserToGroups -AppPools $pools -Groups $groups

Write-Output "Configure AppPool access to performance monitoring done."


