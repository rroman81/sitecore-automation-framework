$ErrorActionPreference = "Stop"

function CleanInstalledXConnectServices {
    [CmdletBinding()]
    Param
    (
        [string]$HostName
    )

    $services = @("IndexWorker", "MarketingAutomationService")

    Write-Output "Cleaning existing xConnect services..."

    foreach ($service in $services) {
        $serviceName = "$HostName-$service"
        if (Get-Service $serviceName -ErrorAction SilentlyContinue) {
            nssm stop $serviceName | Out-Null
            taskkill /F /IM mmc.exe | Out-Null
            nssm remove $serviceName confirm
        }
    }

    Write-Output "Cleaning existing xConnect services done"
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
        [string]$Reason
    )

    if ($Force -or $PSCmdlet.ShouldProcess("IIS", $Reason)) {
        Start-Process "iisreset.exe" -NoNewWindow -Wait
    }
}

function AddAppPoolUserToGroups {
    [CmdletBinding()]
    Param
    (
        [string]$AppPool,
        [string[]]$Groups
    )

    $needIISReset = $false

    foreach ($gr in $Groups) {
        $group = [ADSI]"WinNT://$Env:ComputerName/$gr,group"
        $members = $group.psbase.invoke("Members") | ForEach-Object {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}

        if ($members -contains $AppPool) {
            Write-Warning "'$AppPool' AppPool user exists in '$gr' group"
        }
        else {
            Write-Output "Adding '$AppPool' AppPool user to '$gr' group..."
    
            $ntAccount = New-Object System.Security.Principal.NTAccount("IIS APPPOOL\$AppPool")
            $strSID = $ntAccount.Translate([System.Security.Principal.SecurityIdentifier])
            $user = [ADSI]"WinNT://$strSID"
            $group.Add($user.Path)
            $needIISReset = $true

            Write-Output "Adding '$AppPool' AppPool user to '$gr' group done."
        }
    }

    if ($needIISReset -eq $true) {
        IISReset -Reason "Changes on '$AppPool' AppPool user will take effect after IIS Reset. Do it now?" -Confirm
    }
}

Export-ModuleMember -Function "CleanInstalledXConnectServices"
Export-ModuleMember -Function "AddConnectionString"
Export-ModuleMember -Function "AddAppPoolUserToGroups"