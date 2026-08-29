Set-Location -Path $PSScriptRoot
apm compile --all

$profiles = Get-ChildItem -Path .\profiles

foreach ($profile in $profiles) {
    if ($profile.PSIsContainer) {
        Write-Host "Compiling profile: $($profile.Name)"
        Push-Location -Path $profile.FullName
        apm compile --all
        Pop-Location
    }   
}