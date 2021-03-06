Import-Module "$PSScriptRoot\Logging-Module.psm1" -Force
$ErrorActionPreference = "Stop"

function RemoveTemp {
    Remove-Item -Path "$PSScriptRoot\..\temp" -Recurse -Force | Out-Null
}

function CreateTemp {
    $tempFolder = "$PSScriptRoot\..\temp"
    if (!(Test-Path $tempFolder)) {
        New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null
    }
}

function ShowSteps {
    [CmdletBinding()]
    Param
    (
        [string]$Pipeline
    )

    Write-Output "`n`nSAF will run '$Pipeline' pipeline:`n"
    
    foreach ($step in $global:Pipelines.$Pipeline) {
        if (($step.skip -eq $true) -or (IsStepCompleted -Pipeline $Pipeline -Step $step.name)) {
            Write-Warning "SKIP $($step.name)"
        }
        else {
            Write-Output "- $($step.name)"
        }
    }
    Write-Output ""
    Write-Warning "Starting after 13 seconds..."
    Write-Output ""
    Start-Sleep -s 13
}

function RunSteps {
    [CmdletBinding()]
    Param
    (
        [string]$Pipeline,
        [switch]$Force
    )

    CreateTemp

    if ($Force.IsPresent) {
        EraseHistoryLog -Pipeline $Pipeline
    }

    ShowSteps -Pipeline $Pipeline

    try {
        foreach ($step in ($global:Pipelines.$Pipeline)) {
            
            if (($step.skip -eq $true) -or (IsStepCompleted -Pipeline $Pipeline -Step $step.name)) { continue }

            if ($step.script.StartsWith("/") -or $step.script.StartsWith("\")) {
                & "$PSScriptRoot\..$($step.script)"
            }
            else {
                & $step.script
            }
            
            MarkStepAsCompleted -Pipeline $Pipeline -Step $step.name
        }

        RemoveTemp
    }
    catch {
        $exception = $_.Exception | Format-List -Force | Out-String
        Write-Error $exception
    }
}

Export-ModuleMember -Function "RunSteps"