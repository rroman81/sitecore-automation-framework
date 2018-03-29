Import-Module "$PSScriptRoot\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$hostName = $global:Configuration.xConnect.hostName
$solrServiceName = $global:Configuration.search.solr.serviceName
$services = @("$($hostName)-IndexWorker", "$($hostName)-MarketingAutomationService", "$solrServiceName")
DeleteServices -Services $services