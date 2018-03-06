$ErrorActionPreference = "Stop"

Write-Output "Cleaning installation metadata started..."

$keepSSMS = $global:Configuration.sql.keepSSMS
if($keepSSMS -eq $false) {
    choco uninstall sql-server-management-studio -y --limitoutput
}

Write-Output "Cleaning installation metadata done."