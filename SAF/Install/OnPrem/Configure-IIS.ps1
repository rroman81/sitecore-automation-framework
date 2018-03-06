$ErrorActionPreference = "Stop"

function Initialize-IIS {
    Write-Output "IIS configuration started..."

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
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45 -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45 -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic -All | Out-Null
        Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -All | Out-Null
    }

    Write-Output "IIS configuration done."
}

Initialize-IIS




