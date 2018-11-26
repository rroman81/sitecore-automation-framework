Import-Module "$PSScriptRoot\SSL\SSL-Module.psm1" -Force
$ErrorActionPreference = "Stop"

function EnableIISAdministration {
    $operatingSystem = (Get-WmiObject win32_operatingsystem).Caption
    
    if (($operatingSystem -like '*server*') -or ($operatingSystem -like '*Server*')) {
        if (!(Get-WindowsFeature "Web-Server").Installed) {
            Write-Output "Enabling IIS Administration..."
            Install-WindowsFeature -Name "Web-Server" | Out-Null
        }
    }
    else {
        if ((Get-WindowsOptionalFeature -FeatureName "IIS-WebServer" -Online).State -ne "Enabled") {
            Write-Output "Enabling IIS Administration..."
            Enable-WindowsOptionalFeature -FeatureName "IIS-WebServer" -Online -All | Out-Null
        }
    }

    Get-Module -Name WebAdministration | Remove-Module
    Import-Module -Name WebAdministration
}

<#
.Synopsis 
    Restarts the IIS web server via iisreset.exe.
.Description
    Restarts the IIS Web Server via IISReset.exe with 3 retries.
#>
function Restart-WebServer {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact="Medium")]
    Param
    (
        [string]$Reason,
        [int]$TryNumber = 0,
        [switch]$Force
    )

    if ($Force -or $PSCmdlet.ShouldProcess("IIS", $Reason)) {
        $process = Start-Process "iisreset.exe" -NoNewWindow -Wait -PassThru

        if (($process.ExitCode -gt 0) -and ($TryNumber -lt 3) ) {
            Write-Warning "IIS Reset failed. Retrying..."
            $newTryNumber = $TryNumber + 1
            Restart-WebServer -Reason $Reason -TryNumber $newTryNumber -Force
        }
    }
}

function TestURI {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    Param(
        [Parameter(Position = 0, Mandatory, HelpMessage = "Enter the URI path starting with HTTP or HTTPS")]
        [ValidatePattern( "^(http|https)://" )]
        [string]$URI,
        [ValidateScript( {$_ -ge 0})]
        [int]$Timeout = 30
    )
     
    try {
        
        $paramHash = @{
            UseBasicParsing  = $true
            DisableKeepAlive = $true
            Uri              = $URI
            Method           = 'Head'
            ErrorAction      = 'Stop'
            TimeoutSec       = $Timeout
        }
     
        $test = Invoke-WebRequest @paramHash
       
        if ($test.statuscode -ne 200) {
            return $false
        }
        else {
            return $true
        }
    }
    catch {
        return $false
    }
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

    Write-Output "Adding a new connection string with name '$ConnStringName'..."
    $connStrFile = Join-Path -Path $WebsiteRootDir -ChildPath "\App_Config\ConnectionStrings.config"
    $connStr = "Data Source=$SqlServer;Initial Catalog=$Database;User ID=$Username;Password=$Password"
    
    $xmlDoc = [System.Xml.XmlDocument](Get-Content $connStrFile)
    $newConnStrElement = $xmlDoc.CreateElement("add")
    $newConnStr = $xmlDoc.connectionStrings.AppendChild($newConnStrElement)
    $newConnStr.SetAttribute("name", $ConnStringName)
    $newConnStr.SetAttribute("connectionString", $connStr)
    $xmlDoc.Save($connStrFile)
    Write-Output "Adding a new connection string with name '$ConnStringName' done"
}

function AddAppPoolUserToGroups {
    [CmdletBinding()]
    Param
    (
        [string[]]$AppPools,
        [string[]]$Groups
    )

    $needIISReset = $false

    foreach ($gr in $Groups) {
        $group = [ADSI]"WinNT://$Env:ComputerName/$gr,group"
        $members = $group.psbase.invoke("Members") | ForEach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}

        foreach ($pool in $AppPools) {
            if ($members -contains $pool) {
                Write-Warning "'$pool' AppPool user exists in '$gr' group"
            }
            else {
                Write-Output "Adding '$pool' AppPool user to '$gr' group..."
        
                $ntAccount = New-Object System.Security.Principal.NTAccount("IIS APPPOOL\$pool")
                $strSID = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier])
                $user = [ADSI]"WinNT://$strSID"
                $group.Add($user.Path)
                $needIISReset = $true
    
                Write-Output "Adding '$pool' AppPool user to '$gr' group done."
            }
        }
    }

    if ($needIISReset) {
        Restart-WebServer -Reason "Groups changes will take effect after IIS Reset. Do it now?" -Confirm:$false
    }
}

function HostFileContainsEntry {
    [CmdletBinding()]
    Param(
        [string]$HostName
    )

    $file = Join-Path -Path $($env:windir) -ChildPath "system32\drivers\etc\hosts"
    if (!(Test-Path -Path $file)) {            
        Throw "Hosts file not found."            
    }
    $content = Get-Content $file 
    foreach ($line in $content) {
        if (!$line.StartsWith("#") -and $line -ne "") {
            if ($line.Contains($HostName)) {
                return $true
            }
        }
    }

    return $false
}

function AddHostFileEntry {
    [CmdletBinding()]
    Param(
        [string]$IP,
        [string]$HostName
    )

    $file = Join-Path -Path $($env:windir) -ChildPath "system32\drivers\etc\hosts"            
    if (!(Test-Path -Path $file)) {            
        Throw "Hosts file not found."            
    }
  
    if (HostFileContainsEntry -HostName $HostName) {
        Write-Warning "Hosts file contains entry for '$HostName'. Skipping add entry..."
    }
    else {
        Write-Output "Adding entry to hosts file: '$IP $HostName'..."
        [System.IO.File]::AppendAllText($file, "`r`n$IP`t$HostName")  
    }
}

function CreateBindingWithThumprint {
    [CmdletBinding()]
    Param
    (
        [string]$SiteName,
        [string]$HostName,
        [string]$SSLCert
    )

    $params = @{
        Path     = "$PSScriptRoot\CreateBindingWithThumprint.json"
        SiteName = $SiteName
        HostName = $HostName
        SSLCert  = $SSLCert
    }
    Install-SitecoreConfiguration @params
}

function AddWebBindings {
    [CmdletBinding()]
    Param
    (
        [string]$SiteName,
        [string[]]$HostNames,
        [string]$SSLCert,
        [switch]$Secure
    )

    Write-Output "Adding Web Bindings started..."
    EnableIISAdministration

    foreach ($host in $HostNames) {
        $protocol = "http"
        $port = 80
        if ($PSBoundParameters["Secure"]) {
            $protocol = "https"
            $port = 443
        }
        
        $binding = Get-WebBinding -Name $SiteName -IPAddress "*" -Protocol $protocol -Port $port -HostHeader $host
        
        if ($binding -eq $null) {
            Write-Output "Adding $protocol Web Binding to $SiteName for $host..."
            if ($protocol -eq "https") {
                CreateBindingWithThumprint -SiteName $SiteName -HostName $host -SSLCert $SSLCert
            }
            else {
                New-WebBinding -Name $SiteName -IPAddress "*" -Protocol $protocol -Port $port -HostHeader $host
            }
            
            AddHostFileEntry -IP "127.0.0.1" -HostName $host
        }
        else {
            Write-Warning "$protocol Web Binding on $SiteName for $host exists. Skipping add..."
        }
    }
}

function DeleteIISWebsite {
    [CmdletBinding()]
    Param
    (
        [string]$SiteName
    )

    Write-Output "Deleting IIS Website '$SiteName'..."
    EnableIISAdministration

    if (Test-Path "IIS:\Sites\$SiteName") {
        Remove-Website -Name $SiteName
        Write-Output "'$SiteName' website deleted."
    }
    else {
        Write-Warning -Message "Could not find website '$SiteName'."
    }
}

function DeleteIISAppPool {
    [CmdletBinding()]
    Param
    (
        [string]$AppPoolName
    )

    Write-Output "Deleting IIS AppPool '$AppPoolName'..."
    EnableIISAdministration
   
    if (Test-Path "IIS:\AppPools\$AppPoolName") {
        Remove-WebAppPool -Name $AppPoolName
        Write-Output "'$AppPoolName' IIS AppPool deleted."
    }
    else {
        Write-Warning -Message "Could not find IIS AppPool '$AppPoolName'."
    }
}

Export-ModuleMember -Function "EnableIISAdministration"
Export-ModuleMember -Function "AddWebBindings"
Export-ModuleMember -Function "AddHostFileEntry"
Export-ModuleMember -Function "TestURI"
Export-ModuleMember -Function "AddAppPoolUserToGroups"
Export-ModuleMember -Function "AddConnectionString"
Export-ModuleMember -Function "Restart-WebServer"
Export-ModuleMember -Function "DeleteIISWebsite"
Export-ModuleMember -Function "DeleteIISAppPool"