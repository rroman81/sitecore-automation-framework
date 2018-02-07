$ErrorActionPreference = "Stop"

function CleanInstalledXConnectServices {
    [CmdletBinding()]
    Param
    (
        [string]$HostName
    )

    $services = @("IndexWorker", "MarketingAutomationService")

    Write-Host "Cleaning existing xConnect services..."

    foreach ($service in $services) {
        $serviceName = "$HostName-$service"
        if (Get-Service $serviceName -ErrorAction SilentlyContinue) {
            nssm stop $serviceName | Out-Null
            taskkill /F /IM mmc.exe | Out-Null
            nssm remove $serviceName confirm
        }
    }

    Write-Host "Cleaning existing xConnect services done"
}

Export-ModuleMember -Function "CleanInstalledXConnectServices"