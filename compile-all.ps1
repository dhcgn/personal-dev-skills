<#
.SYNOPSIS
    Deploys the root package and every profile locally.

.DESCRIPTION
    Root: "apm install" deploys the local .apm/ skills, "apm compile --clean" regenerates AGENTS.md.
    Each profiles\* folder: "apm update --yes" refreshes remote refs, "apm install" picks up
    edits to local path dependencies (apm update does not re-read local content).

.EXAMPLE
    .\compile-all.ps1
#>

if (-not (Get-Command apm -ErrorAction SilentlyContinue)) {
    Write-Error "apm not found, install it: https://microsoft.github.io/apm/getting-started/installation/"
    exit 1
}

# Stop at the first failing apm call instead of reporting success (PowerShell 7.3+)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

Push-Location -Path $PSScriptRoot
try {
    apm install
    apm compile --clean

    $profiles = @(Get-ChildItem -Path .\profiles -Directory)
    for ($i = 0; $i -lt $profiles.Count; $i++) {
        $p = $profiles[$i]
        Write-Progress -Activity "Deploying profiles" -Status $p.Name -PercentComplete (100 * $i / $profiles.Count)
        Push-Location -Path $p.FullName
        try {
            apm update --yes
            apm install
        } finally {
            Pop-Location
        }
    }
} finally {
    Write-Progress -Activity "Deploying profiles" -Completed
    Pop-Location
}
