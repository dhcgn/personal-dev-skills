Set-Location -Path $PSScriptRoot

apm install
apm compile

$profiles = Get-ChildItem -Path .\profiles

foreach ($profile in $profiles) {
    if ($profile.PSIsContainer) {
        Write-Host "Compiling profile: $($profile.Name)"
        Push-Location -Path $profile.FullName
        apm install
        apm compile
        Pop-Location
    }   
}