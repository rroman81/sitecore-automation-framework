
$ErrorActionPreference = "Stop"

Write-Output "SQL DAC Framework configuration started..."
choco upgrade sql2016-dacframework
Write-Output "SQL DAC Framework configuration done."