$ErrorActionPreference = "Stop"

function RefreshEnvironment {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
    refreshenv
}

function TestURI {
    [cmdletbinding(DefaultParameterSetName = "Default")]
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
    
function DownloadAndUnzip {
    Param(
        [string]$toolName,
        [string]$toolFolder,
        [string]$toolZip,
        [string]$toolSourceFile,
        [string]$installRoot
    )

    if (!(Test-Path -Path $toolFolder)) {
        if (!(Test-Path -Path $toolZip)) {
            Write-Output "Downloading $toolName..."
            Start-BitsTransfer -Source $toolSourceFile -Destination $toolZip
        }

        Write-Output "Extracting $toolName to $toolFolder..."
        Expand-Archive $toolZip -DestinationPath $installRoot
    }
}

function DeleteServices {
    [CmdletBinding()]
    Param
    (
        [string]$HostName,
        [string[]]$Services
    )

    Write-Output "Deleting existing services..."

    foreach ($service in $Services) {
        $serviceName = "$HostName-$service"
        if (Get-Service $serviceName -ErrorAction SilentlyContinue) {
            nssm stop $serviceName | Out-Null
            taskkill /F /IM mmc.exe | Out-Null
            nssm remove $serviceName confirm
        }
    }

    Write-Output "Deleting existing services done."
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

function IISReset {
    [CmdletBinding(SupportsShouldProcess = $true)]
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
            IISReset -Reason $Reason -TryNumber $newTryNumber -Force
        }
    }
}

function InstallSolr {
    [CmdletBinding()]
    Param
    (
        [string]$Version,
        [string]$InstallDir,
        [string]$HostName,
        [int]$Port,
        [string]$ServiceDir,
        [string]$ServiceName,
        [string]$ServiceDisplayName,
        [string]$ServiceDescription,
        [bool]$SolrSSL = $true
    )
   
    Write-Output "Solr installation started..."
    
    $downloadFolder = "~\Downloads"
    $solrPackage = "https://archive.apache.org/dist/lucene/solr/$Version/solr-$Version.zip"
    $solrZip = "$downloadFolder\$ServiceName.zip"
    DownloadAndUnzip "Solr" $ServiceDir $solrZip $solrPackage $InstallDir
    
    $JREVersion = Get-ChildItem "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment" | Select-Object -expa pschildname -Last 1
    $JREPath = "C:\Program Files\Java\jre$JREVersion"
    $jreVal = [Environment]::GetEnvironmentVariable("JAVA_HOME", [EnvironmentVariableTarget]::Machine)
    if ($jreVal -ne $JREPath) {
        Write-Output "Setting JAVA_HOME environment variable"
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $JREPath, [EnvironmentVariableTarget]::Machine)
    }
    
    if ($solrSSL -eq $false) {
        if (!(Test-Path -Path "$ServiceDir\bin\solr.in.cmd.old")) {
            Write-Output "Rewriting solr config"
    
            $cfg = Get-Content "$ServiceDir\bin\solr.in.cmd"
            Rename-Item "$ServiceDir\bin\solr.in.cmd" "$ServiceDir\bin\solr.in.cmd.old"
            $newCfg = $newCfg | ForEach-Object { $_ -replace "REM set SOLR_HOST=192.168.1.1", "set SOLR_HOST=$HostName" }
            $newCfg | Set-Content "$ServiceDir\bin\solr.in.cmd"
        }
    }
    
    if ($HostName -ne "localhost") {
        $HostNameFileName = "c:\\windows\system32\drivers\etc\hosts"
        $HostNameFile = [System.Io.File]::ReadAllText($HostNameFileName)
        if (!($HostNameFile -like "*$HostName*")) {
            Write-Output "Updating host file"
            "`r`n127.0.0.1`t$HostName" | Add-Content $HostNameFileName
        }
    }
    
    if ($solrSSL -eq $true) {
        $existingCert = Get-ChildItem Cert:\LocalMachine\Root | Where-Object FriendlyName -eq "$ServiceName"
        if (!($existingCert)) {
            Write-Output "Creating & trusting an new SSL Cert for $HostName"
    
            # Generate a cert
            # https://docs.microsoft.com/en-us/powershell/module/pkiclient/new-selfsignedcertificate?view=win10-ps
            $cert = New-SelfSignedCertificate -FriendlyName "$ServiceName" -DnsName "$HostName" -CertStoreLocation "cert:\LocalMachine" -NotAfter (Get-Date).AddYears(10)
    
            # Trust the cert
            # https://stackoverflow.com/questions/8815145/how-to-trust-a-certificate-in-windows-powershell
            $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
            $store.Open("ReadWrite")
            $store.Add($cert)
            $store.Close()
    
            # Remove the untrusted copy of the cert
            $cert | Remove-Item
        }
    
        # Export the cert to pfx using solr's default password
        if (!(Test-Path -Path "$ServiceDir\server\etc\solr-ssl.keystore.pfx")) {
            Write-Output "Exporting cert for Solr to use"
    
            $cert = Get-ChildItem Cert:\LocalMachine\Root | Where-Object FriendlyName -eq "$ServiceName"
        
            $certStore = "$ServiceDir\server\etc\solr-ssl.keystore.pfx"
            $certPwd = ConvertTo-SecureString -String "secret" -Force -AsPlainText
            $cert | Export-PfxCertificate -FilePath $certStore -Password $certpwd | Out-Null
        }
    
        # Update solr cfg to use keystore & right host name
        if (!(Test-Path -Path "$ServiceDir\bin\solr.in.cmd.old")) {
            Write-Output "Rewriting solr config"
    
            $cfg = Get-Content "$ServiceDir\bin\solr.in.cmd"
            Rename-Item "$ServiceDir\bin\solr.in.cmd" "$ServiceDir\bin\solr.in.cmd.old"
            $newCfg = $cfg | ForEach-Object { $_ -replace "REM set SOLR_SSL_KEY_STORE=etc/solr-ssl.keystore.jks", "set SOLR_SSL_KEY_STORE=$certStore" }
            $newCfg = $newCfg | ForEach-Object { $_ -replace "REM set SOLR_SSL_KEY_STORE_PASSWORD=secret", "set SOLR_SSL_KEY_STORE_PASSWORD=secret" }
            $newCfg = $newCfg | ForEach-Object { $_ -replace "REM set SOLR_SSL_TRUST_STORE=etc/solr-ssl.keystore.jks", "set SOLR_SSL_TRUST_STORE=$certStore" }
            $newCfg = $newCfg | ForEach-Object { $_ -replace "REM set SOLR_SSL_TRUST_STORE_PASSWORD=secret", "set SOLR_SSL_TRUST_STORE_PASSWORD=secret" }
            $newCfg = $newCfg | ForEach-Object { $_ -replace "REM set SOLR_HOST=192.168.1.1", "set SOLR_HOST=$HostName" }
            $newCfg | Set-Content "$ServiceDir\bin\solr.in.cmd"
        }
    }
    
    $svc = Get-Service "$ServiceName" -ErrorAction SilentlyContinue
    if (!($svc)) {
        Write-Output "Installing Solr service"
        nssm install "$ServiceName" "$ServiceDir\bin\solr.cmd" "-f" "-p $Port"
        nssm set "$ServiceName" DisplayName "$ServiceDisplayName" 
        nssm set "$ServiceName" Description "$ServiceDescription"
        $svc = Get-Service "$ServiceName" -ErrorAction SilentlyContinue
    }
    if ($svc.Status -ne "Running") {
        Write-Output "Starting Solr service"
        Start-Service "$ServiceName"
    }
    
    Write-Output "Solr installation done."
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

        foreach($pool in $AppPools){
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

    if ($needIISReset -eq $true) {
        IISReset -Reason "Groups changes will take effect after IIS Reset. Do it now?" -Confirm
    }
}

Export-ModuleMember -Function "DeleteServices"
Export-ModuleMember -Function "AddConnectionString"
Export-ModuleMember -Function "AddAppPoolUserToGroups"
Export-ModuleMember -Function "DownloadAndUnzip"
Export-ModuleMember -Function "InstallSolr"
Export-ModuleMember -Function "TestURI"
Export-ModuleMember -Function "RefreshEnvironment"