# AgentMonitor - Simple Startup Script
# ADD YOUR GEMINI API KEY HERE
$GEMINI_API_KEY = "AIzaSyCALdYnS-PTEo_kumar9NUtKpkxipfOoCE"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $projectRoot "backend"
$frontendDir = Join-Path $projectRoot "frontend"

Write-Host ""
Write-Host "Starting AgentMonitor..." -ForegroundColor Green
Write-Host ""

# Install Backend
Write-Host "Installing backend packages..." -ForegroundColor Cyan
Push-Location $backendDir
python.exe -m pip install -q -r requirements.txt 2>&1 | Out-Null
Pop-Location
Write-Host "Backend packages installed" -ForegroundColor Green
Write-Host ""

# Install Frontend
Write-Host "Installing frontend packages..." -ForegroundColor Cyan
if (-not (Test-Path "$frontendDir\node_modules")) {
    Push-Location $frontendDir
    npm install --silent 2>&1 | Out-Null
    Pop-Location
}
Write-Host "Frontend packages installed" -ForegroundColor Green
Write-Host ""

# Start Backend
Write-Host "Starting Backend (port 5000)..." -ForegroundColor Cyan
$backendScript = @"
`$env:GEMINI_API_KEY = "$GEMINI_API_KEY"
Set-Location "$backendDir"
python.exe -c "import uvicorn; from app import app; uvicorn.run(app, host='0.0.0.0', port=5000, log_level='info')"
"@
Start-Process powershell -ArgumentList @("-NoExit", "-Command", $backendScript) -WindowStyle Normal
Start-Sleep -Seconds 3

# Start Frontend
Write-Host "Starting Frontend (port 3000)..." -ForegroundColor Cyan
$frontendScript = @"
Set-Location "$frontendDir"
npm start
"@
Start-Process powershell -ArgumentList @("-NoExit", "-Command", $frontendScript) -WindowStyle Normal
Start-Sleep -Seconds 8

# Open Browser
Start-Process "http://localhost:3000"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "READY! Application opened in browser" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Frontend:  http://localhost:3000" -ForegroundColor Yellow
Write-Host "Backend:   http://localhost:5000" -ForegroundColor Yellow
Write-Host ""
Write-Host "Login with: admin / admin123" -ForegroundColor Yellow
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green

