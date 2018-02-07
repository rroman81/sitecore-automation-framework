$ErrorActionPreference = "Stop"

Write-Host "IIS URL Rewrite configuration started..."
choco upgrade urlrewrite
Write-Host "IIS URL Rewrite configuration done."