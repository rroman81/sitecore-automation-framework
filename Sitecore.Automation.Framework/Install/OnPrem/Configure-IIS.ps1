$ErrorActionPreference = "Stop"

function EnableWindowsFeatures {
    $windowsFeatures = @("IIS-WebServerRole", "IIS-WebServer", "IIS-CommonHttpFeatures", 
        "IIS-CommonHttpFeatures", "IIS-HttpErrors", "IIS-HttpRedirect", "IIS-ApplicationDevelopment",
        "IIS-NetFxExtensibility45", "IIS-HealthAndDiagnostics", "IIS-HttpLogging", "IIS-LoggingLibraries",
        "IIS-RequestMonitor", "IIS-HttpTracing", "IIS-Security", "IIS-RequestFiltering", "IIS-Performance", 
        "IIS-WebServerManagementTools", "IIS-IIS6ManagementCompatibility", "IIS-Metabase", "IIS-ManagementConsole",
        "IIS-BasicAuthentication", "IIS-WindowsAuthentication", "IIS-StaticContent", "IIS-DefaultDocument",
        "IIS-WebSockets", "IIS-ApplicationInit", "IIS-NetFxExtensibility45", "IIS-ISAPIExtensions",
        "IIS-ISAPIFilter", "IIS-HttpCompressionStatic", "IIS-ASPNET45")

    foreach ($feature in $windowsFeatures) {
        if ((Get-WindowsOptionalFeature -FeatureName $feature -Online).State -ne "Enabled") {
            Enable-WindowsOptionalFeature -FeatureName $feature -Online -All | Out-Null
        }
    }
}

function EnableWindesServerFeatures {
    $windowsServerFeatures = @("Web-Server", "Web-WebServer", "Web-Common-Http", "Web-Default-Doc",
    "Web-Http-Errors", "Web-Static-Content", "Web-Http-Redirect", "Web-Health", "Web-Http-Logging",
    "Web-Log-Libraries", "Web-Request-Monitor", "Web-Http-Tracing", "Web-Performance",
    "Web-Stat-Compression", "Web-Dyn-Compression", "Web-Security", "Web-Filtering",
    "Web-Basic-Auth", "Web-Basic-Auth", "Web-App-Dev", "Web-Net-Ext45", "Web-AppInit",
    "Web-Asp-Net45", "Web-ISAPI-Ext", "Web-ISAPI-Filter", "Web-Includes",
    "Web-WebSockets", "Web-Mgmt-Tools", "Web-Mgmt-Console")

    foreach ($feature in $windowsServerFeatures) {
        if (!(Get-WindowsFeature $feature).Installed) {
            Install-WindowsFeature -Name $feature | Out-Null
        }
    }
}
function Initialize-IIS {
    Write-Output "IIS configuration started..."

    $operatingSystem = (Get-WmiObject win32_operatingsystem).Caption
    
    if (($operatingSystem -like '*server*') -or ($operatingSystem -like '*Server*')) {
        EnableWindesServerFeatures
    }
    else {
        EnableWindowsFeatures
    }

    Write-Output "IIS configuration done."
}

Initialize-IIS




