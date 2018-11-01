Import-Module "$PSScriptRoot\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

$prefix = $global:Configuration.prefix
$password = $global:Configuration.password
$exportPath = Get-Location

ExportCerts -Prefix $prefix -ExportPath $exportPath -Password $password