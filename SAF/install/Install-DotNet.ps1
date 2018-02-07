$ErrorActionPreference = "Stop"

Write-Host "Install .Net Framework 4.6.2 started..."

if (Get-ChildItem "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\" | Get-ItemPropertyValue -Name Release | ForEach-Object { $_ -ge 394802 }) {
    Write-Host ".Net Framework 4.6.2 or newer is already installed."
}
else {
    choco install dotnet4.6.2
}

Write-Host "Install .Net Framework 4.6.2 done."