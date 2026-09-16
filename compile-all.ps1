Set-Location -Path $PSScriptRoot

apm install -t opencode --update
apm compile

$profiles = Get-ChildItem -Path .\profiles

foreach ($p in $profiles) {
    if ($p.PSIsContainer) {
        Write-Host "Compiling profile: $($p.Name)"
        Push-Location -Path $p.FullName
        apm install --update
        apm compile
        Pop-Location
    }   
}