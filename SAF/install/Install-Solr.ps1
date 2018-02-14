$ErrorActionPreference = "Stop"

Write-Output "Solr installation started..."

$version = $global:Configuration.search.solr.version
$solrPackage = "https://archive.apache.org/dist/lucene/solr/$version/solr-$version.zip"
$installFolder = $global:Configuration.search.solr.installDir
$hostName = $global:Configuration.search.solr.hostName
$port = $global:Configuration.search.solr.port
$serviceName = $global:Configuration.search.solr.serviceName
$serviceDisplayName = $global:Configuration.search.solr.serviceDisplayName
$serviceDesctiption = $global:Configuration.search.solr.serviceDescription
$downloadFolder = "~\Downloads"
$solrSSL = $true
$JREVersion = Get-ChildItem "HKLM:\SOFTWARE\JavaSoft\Java Runtime Environment" | Select-Object -expa pschildname -Last 1
$JREPath = "C:\Program Files\Java\jre$JREVersion"
$serviceRoot = $global:Items.SolrServiceDir

function DownloadAndUnzipIfRequired {
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
# download & extract the solr archive to the right folder
$solrZip = "$downloadFolder\$serviceName.zip"
DownloadAndUnzipIfRequired "Solr" $serviceRoot $solrZip $solrPackage $installFolder

# Ensure Java environment variable
$jreVal = [Environment]::GetEnvironmentVariable("JAVA_HOME", [EnvironmentVariableTarget]::Machine)
if ($jreVal -ne $JREPath) {
    Write-Output "Setting JAVA_HOME environment variable"
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $JREPath, [EnvironmentVariableTarget]::Machine)
}

# if we're using HTTP
if ($solrSSL -eq $false) {
    # Update solr cfg to use right host name
    if (!(Test-Path -Path "$serviceRoot\bin\solr.in.cmd.old")) {
        Write-Output "Rewriting solr config"

        $cfg = Get-Content "$serviceRoot\bin\solr.in.cmd"
        Rename-Item "$serviceRoot\bin\solr.in.cmd" "$serviceRoot\bin\solr.in.cmd.old"
        $newCfg = $newCfg | % { $_ -replace "REM set SOLR_HOST=192.168.1.1", "set SOLR_HOST=$hostName" }
        $newCfg | Set-Content "$serviceRoot\bin\solr.in.cmd"
    }
}

# Ensure the solr host name is in your hosts file
if ($hostName -ne "localhost") {
    $hostNameFileName = "c:\\windows\system32\drivers\etc\hosts"
    $hostNameFile = [System.Io.File]::ReadAllText($hostNameFileName)
    if (!($hostNameFile -like "*$hostName*")) {
        Write-Output "Updating host file"
        "`r`n127.0.0.1`t$hostName" | Add-Content $hostNameFileName
    }
}

# if we're using HTTPS
if ($solrSSL -eq $true) {
    # Generate SSL cert
    $existingCert = Get-ChildItem Cert:\LocalMachine\Root | where FriendlyName -eq "$serviceName"
    if (!($existingCert)) {
        Write-Output "Creating & trusting an new SSL Cert for $hostName"

        # Generate a cert
        # https://docs.microsoft.com/en-us/powershell/module/pkiclient/new-selfsignedcertificate?view=win10-ps
        $cert = New-SelfSignedCertificate -FriendlyName "$serviceName" -DnsName "$hostName" -CertStoreLocation "cert:\LocalMachine" -NotAfter (Get-Date).AddYears(10)

        # Trust the cert
        # https://stackoverflow.com/questions/8815145/how-to-trust-a-certificate-in-windows-powershell
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
        $store.Open("ReadWrite")
        $store.Add($cert)
        $store.Close()

        # remove the untrusted copy of the cert
        $cert | Remove-Item
    }

    # export the cert to pfx using solr's default password
    if (!(Test-Path -Path "$serviceRoot\server\etc\solr-ssl.keystore.pfx")) {
        Write-Output "Exporting cert for Solr to use"

        $cert = Get-ChildItem Cert:\LocalMachine\Root | where FriendlyName -eq "$serviceName"
    
        $certStore = "$serviceRoot\server\etc\solr-ssl.keystore.pfx"
        $certPwd = ConvertTo-SecureString -String "secret" -Force -AsPlainText
        $cert | Export-PfxCertificate -FilePath $certStore -Password $certpwd | Out-Null
    }

    # Update solr cfg to use keystore & right host name
    if (!(Test-Path -Path "$serviceRoot\bin\solr.in.cmd.old")) {
        Write-Output "Rewriting solr config"

        $cfg = Get-Content "$serviceRoot\bin\solr.in.cmd"
        Rename-Item "$serviceRoot\bin\solr.in.cmd" "$serviceRoot\bin\solr.in.cmd.old"
        $newCfg = $cfg | % { $_ -replace "REM set SOLR_SSL_KEY_STORE=etc/solr-ssl.keystore.jks", "set SOLR_SSL_KEY_STORE=$certStore" }
        $newCfg = $newCfg | % { $_ -replace "REM set SOLR_SSL_KEY_STORE_PASSWORD=secret", "set SOLR_SSL_KEY_STORE_PASSWORD=secret" }
        $newCfg = $newCfg | % { $_ -replace "REM set SOLR_SSL_TRUST_STORE=etc/solr-ssl.keystore.jks", "set SOLR_SSL_TRUST_STORE=$certStore" }
        $newCfg = $newCfg | % { $_ -replace "REM set SOLR_SSL_TRUST_STORE_PASSWORD=secret", "set SOLR_SSL_TRUST_STORE_PASSWORD=secret" }
        $newCfg = $newCfg | % { $_ -replace "REM set SOLR_HOST=192.168.1.1", "set SOLR_HOST=$hostName" }
        $newCfg | Set-Content "$serviceRoot\bin\solr.in.cmd"
    }
}

# install the service & runs
$svc = Get-Service "$serviceName" -ErrorAction SilentlyContinue
if (!($svc)) {
    Write-Output "Installing Solr service"
    nssm install $serviceName "$serviceRoot\bin\solr.cmd" "-f" "-p $port"
    nssm set $serviceName DisplayName $serviceDisplayName 
    nssm set $serviceName Description $serviceDesctiption
    $svc = Get-Service "$serviceName" -ErrorAction SilentlyContinue
}
if ($svc.Status -ne "Running") {
    Write-Output "Starting Solr service"
    Start-Service "$serviceName"
}

Write-Output "Solr installation done."