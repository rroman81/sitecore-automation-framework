$ErrorActionPreference = "Stop"

Write-Host "Install Non-Sucking Service Manager started..."
choco upgrade nssm -y
Write-Host "Install Non-Sucking Service Manager done."