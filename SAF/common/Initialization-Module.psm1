$ErrorActionPreference = "Stop"
function ConfigureChoco {
    Write-Warning "SAF needs Choco. Installation will start after 3 seconds."
    try {
        choco
        choco upgrade chocolatey
    }
    catch {
        Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
    }
    choco feature enable -n allowGlobalConfirmation
    Write-Warning "SAF has its Choco!"
}

Export-ModuleMember -Function "ConfigureChoco"