Import-Module "$PSScriptRoot\..\..\Common\Utils-Module.psm1" -Force
$ErrorActionPreference = "Stop"

Write-Output "Configure .Net Framework started..."

if (Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release | ForEach-Object { $_ -ge 394802 }) {
    Write-Output ".Net Framework 4.6.2 or newer is already installed. Skipping install..."
}
else {
    if ($global:Configuration.offlineMode -eq $false) {
        choco install dotnet4.6.2 --limitoutput
        RefreshEnvironment
        Write-Output "Install .Net Framework 4.6.2 done."
    }
    else {
        Write-Warning "SAF is running in offline mode. It assumes that you have installed .NET Framework 4.6.2 or newer manually!"
        Start-Sleep -s 5
    }
}

Write-Output "Configure .Net Framework done."

