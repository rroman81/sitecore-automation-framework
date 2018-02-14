$ErrorActionPreference = "Stop"
function ConfigureChoco {
    Write-Output "Chocolatey configuration started..."
    try {
        choco
        choco upgrade chocolatey
    }
    catch {
        Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
    }
    choco feature enable -n allowGlobalConfirmation
    Write-Output "Chocolatey configuration done."
}

function InitializeSAF {
    Write-Warning "SAF initialization will start after 3 seconds."
    Start-Sleep -s 3

    ConfigureChoco
    Write-Warning "SAF initialization done."
}

Export-ModuleMember -Function "InitializeSAF"