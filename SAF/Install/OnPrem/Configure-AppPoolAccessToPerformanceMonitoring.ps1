Import-Module "$PSScriptRoot\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Configure AppPool access to performance monitoring started..."

$groups = @("Performance Log Users", "Performance Monitor Users")

$pools = @()

foreach ($server in $global:Configuration.sitecore) {
    $pools += $server.hostName
}

if ($global:Configuration.processing.hostName -ne $null) {
    $pools += $global:Configuration.processing.hostName
}

if ($global:Configuration.reporting.hostName -ne $null) {
    $pools += $global:Configuration.reporting.hostName
}

if ($global:Configuration.collection.hostName -ne $null) {
    $pools += $global:Configuration.collection.hostName
}

if ($global:Configuration.collectionSearch.hostName -ne $null) {
    $pools += $global:Configuration.collectionSearch.hostName
}

if ($global:Configuration.automationOperations.hostName -ne $null) {
    $pools += $global:Configuration.automationOperations.hostName
}

if ($global:Configuration.automationReporting.hostName -ne $null) {
    $pools += $global:Configuration.automationReporting.hostName
}

if ($global:Configuration.referenceData.hostName -ne $null) {
    $pools += $global:Configuration.referenceData.hostName
}

AddAppPoolUserToGroups -AppPools $pools -Groups $groups

Write-Output "Configure AppPool access to performance monitoring done."


