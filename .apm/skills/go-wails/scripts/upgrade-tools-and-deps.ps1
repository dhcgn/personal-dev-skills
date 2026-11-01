# Check Go version
Write-Host "Checking Go version..." -ForegroundColor Cyan

# Get local Go version
$localGoOutput = go version
$localVersion = $localGoOutput -replace 'go version go(\d+\.\d+\.\d+).*', '$1'

# Get latest Go version from web
$webResponse = (Invoke-WebRequest https://go.dev/VERSION?m=text -ErrorAction Stop).Content
$latestVersion = $webResponse.Split("`n")[0].Trim() -replace 'go(\d+\.\d+\.\d+).*', '$1'

# Compare versions
if ($localVersion -eq $latestVersion) {
    Write-Host "✓ Go version is up to date: $localVersion" -ForegroundColor Green
} else {
    Write-Host "⚠ Version mismatch detected:" -ForegroundColor Yellow
    Write-Host "  Local version:  $localVersion" -ForegroundColor Yellow
    Write-Host "  Latest version: $latestVersion" -ForegroundColor Yellow
}

Write-Host ""

# Upgrade steps
$totalSteps = 3
$currentStep = 0

$currentStep++
Write-Progress -Activity "Upgrading tools and dependencies" -Status "Step ${currentStep}/${totalSteps}: Updating Go dependencies" -PercentComplete (($currentStep / $totalSteps) * 100)
go get -u ./...
go mod tidy

$currentStep++
Write-Progress -Activity "Upgrading tools and dependencies" -Status "Step ${currentStep}/${totalSteps}: Updating Wails CLI" -PercentComplete (($currentStep / $totalSteps) * 100)
wails3 update cli

$currentStep++
Write-Progress -Activity "Upgrading tools and dependencies" -Status "Step ${currentStep}/${totalSteps}: Updating npm dependencies" -PercentComplete (($currentStep / $totalSteps) * 100)
Push-Location ./frontend
npm update --save
Pop-Location

Write-Progress -Activity "Upgrading tools and dependencies" -Completed