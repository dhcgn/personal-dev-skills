<#
.SYNOPSIS
    Sets the version in apm.yml files.

.DESCRIPTION
    Updates the "version:" field in $PSScriptRoot\apm.yml and in every
    $PSScriptRoot\profiles\*\apm.yml. No other locations are searched.

.PARAMETER NewVersion
    The new semantic version (e.g. "1.2.3"). If "0.0.0", exits without changes.

.EXAMPLE
    .\set-version-in-all-apm.ps1 -NewVersion "1.2.3"
#>
Param(
    [string]$NewVersion = "0.0.0"
)

if ($NewVersion -eq "0.0.0") {
    Write-Host "No new version specified. Exiting without making changes."
    exit
} else {
    Write-Host "Updating version to: $NewVersion"
}

$apmFiles = Get-Item -Path (Join-Path $PSScriptRoot "apm.yml"), (Join-Path $PSScriptRoot "profiles\*\apm.yml") -ErrorAction SilentlyContinue

foreach ($file in $apmFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $updatedContent = $content -replace 'version:\s*\d+\.\d+\.\d+', "version: $NewVersion"
    Set-Content -Path $file.FullName -Value $updatedContent -NoNewline
    Write-Host "Updated version in: $($file.FullName)"
}