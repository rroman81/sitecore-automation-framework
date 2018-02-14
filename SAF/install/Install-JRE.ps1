$ErrorActionPreference = "Stop"

Write-Output "Java Runtime Environment configuration started..."
choco upgrade jre8 -PackageParameters "/exclude:32" -y
Write-Output "Java Runtime Environment configuration done."