$ErrorActionPreference = "Stop"
. "$PSScriptRoot\..\Install\InstallParams.ps1"
function GetOrCreateHistoryLogFile {
    [CmdletBinding()]
    Param
    (
        [string]$Pipeline
    )

    $historyFile = "$SAFInstallDir/$Pipeline-history.txt"
    
    if (!(Test-Path $historyFile)) {
        New-Item $historyFile -ItemType File -Force 
    }

    return $historyFile
}

function IsStepCompleted {
    [CmdletBinding()]
    Param
    (
        [string]$Pipeline,
        [string]$Step
    )

    $historyFile = GetOrCreateHistoryLogFile -Pipeline $Pipeline
    foreach ($line in Get-Content $historyFile) {
        if ($line -eq $Step) {
            return $true
        }
    }

    return $false
}

function MarkStepAsCompleted {
    [CmdletBinding()]
    Param
    (
        [string]$Pipeline,
        [string]$Step
    )

    $historyFile = GetOrCreateHistoryLogFile -Pipeline $Pipeline
    $Step | Out-File -FilePath $historyFile -Append
    # Add-Content -Path $historyFile -Value $Step -Encoding "UTF8" -UseTransaction -Force
}

function EraseHistoryLog {
    [CmdletBinding()]
    Param
    (
        [string]$Pipeline
    )

    $historyFile = GetOrCreateHistoryLogFile -Pipeline $Pipeline
    Clear-Content $historyFile -Force
}

Export-ModuleMember -Function "MarkStepAsCompleted"
Export-ModuleMember -Function "IsStepCompleted"
Export-ModuleMember -Function "EraseHistoryLog"