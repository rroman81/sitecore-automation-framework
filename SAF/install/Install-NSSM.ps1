$ErrorActionPreference = "Stop"

Write-Output "Install Non-Sucking Service Manager started..."
choco upgrade nssm -y
Write-Output "Install Non-Sucking Service Manager done."