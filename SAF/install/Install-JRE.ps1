$ErrorActionPreference = "Stop"

Write-Host "Java Runtime Environment configuration started..."
choco upgrade jre8 -PackageParameters "/exclude:32" -y
Write-Host "Java Runtime Environment configuration done."