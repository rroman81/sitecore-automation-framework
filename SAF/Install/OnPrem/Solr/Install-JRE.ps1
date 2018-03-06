Import-Module "$PSScriptRoot\..\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Java Runtime Environment configuration started..."
choco upgrade jre8 -PackageParameters "/exclude:32" -y --limitoutput
RefreshEnvironment
Write-Output "Java Runtime Environment configuration done."