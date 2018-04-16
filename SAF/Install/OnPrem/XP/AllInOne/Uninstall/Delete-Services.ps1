Import-Module "$PSScriptRoot\..\..\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$hostName = $global:Configuration.xConnect.hostName
$services = @("$($hostName)-IndexWorker", "$($hostName)-MarketingAutomationService")
DeleteServices -Services $services