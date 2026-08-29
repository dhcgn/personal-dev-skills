Set-Location -Path $PSScriptRoot

apm install
apm compile

$profiles = Get-ChildItem -Path .\profiles

foreach ($p in $profiles) {
    if ($p.PSIsContainer) {
        Write-Host "Compiling profile: $($p.Name)"
        Push-Location -Path $p.FullName
        apm install
        apm compile
        Pop-Location
    }   
}