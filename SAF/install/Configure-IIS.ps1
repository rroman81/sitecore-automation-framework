$ErrorActionPreference = "Stop"

function Initialize-IIS {
    Write-Host "IIS configuration started..."

    $operatingSystem = (Get-WmiObject win32_operatingsystem).Caption
    
    if (($operatingSystem -like '*server*') -or ($operatingSystem -like '*Server*')) {
        Install-WindowsFeature Web-Server
        Install-WindowsFeature Web-WebServer
        Install-WindowsFeature Web-Common-Http
        Install-WindowsFeature Web-Default-Doc
        Install-WindowsFeature Web-Http-Errors
        Install-WindowsFeature Web-Static-Content
        Install-WindowsFeature Web-Http-Redirect
        Install-WindowsFeature Web-Health
        Install-WindowsFeature Web-Http-Logging
        Install-WindowsFeature Web-Log-Libraries
        Install-WindowsFeature Web-Request-Monitor
        Install-WindowsFeature Web-Http-Tracing
        Install-WindowsFeature Web-Performance
        Install-WindowsFeature Web-Stat-Compression
        Install-WindowsFeature Web-Dyn-Compression
        Install-WindowsFeature Web-Security
        Install-WindowsFeature Web-Filtering
        Install-WindowsFeature Web-Basic-Auth
        Install-WindowsFeature Web-App-Dev
        Install-WindowsFeature Web-Net-Ext45
        Install-WindowsFeature Web-AppInit
        Install-WindowsFeature Web-Asp-Net45
        Install-WindowsFeature Web-ISAPI-Ext
        Install-WindowsFeature Web-ISAPI-Filter
        Install-WindowsFeature Web-Includes
        Install-WindowsFeature Web-WebSockets
        Install-WindowsFeature Web-Mgmt-Tools
        Install-WindowsFeature Web-Mgmt-Console
    }
    else {
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45 | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45 | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 | Out-Null
    }

    Write-Host "IIS configuration done."
}

Initialize-IIS




