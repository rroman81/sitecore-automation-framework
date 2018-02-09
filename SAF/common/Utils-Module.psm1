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

function AddConnectionString {
    [CmdletBinding()]
    Param
    (
        [string]$SqlServer,
        [string]$Database,
        [string]$Username,
        [string]$Password,
        [string]$WebsiteRootDir,
        [string]$ConnStringName

    )

    Write-Host "Adding a new connection string with name '$ConnStringName'..."
    $connStrFile = Join-Path -Path $WebsiteRootDir -ChildPath "\App_Config\ConnectionStrings.config"
    $connStr = "Data Source=$SqlServer;Initial Catalog=$Database;User ID=$Username;Password=$Password"
    
    $xmlDoc = [System.Xml.XmlDocument](Get-Content $connStrFile)
    $newConnStrElement = $xmlDoc.CreateElement("add")
    $newConnStr = $xmlDoc.connectionStrings.AppendChild($newConnStrElement)
    $newConnStr.SetAttribute("name", $ConnStringName)
    $newConnStr.SetAttribute("connectionString", $connStr)
    $xmlDoc.Save($connStrFile)
    Write-Host "Adding a new connection string with name '$ConnStringName' done"
}

Export-ModuleMember -Function "CleanInstalledXConnectServices"
Export-ModuleMember -Function "AddConnectionString"