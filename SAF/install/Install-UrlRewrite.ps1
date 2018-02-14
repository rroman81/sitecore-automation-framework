$ErrorActionPreference = "Stop"

Write-Output "IIS URL Rewrite configuration started..."
choco upgrade urlrewrite
Write-Output "IIS URL Rewrite configuration done."