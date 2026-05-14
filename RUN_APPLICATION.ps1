# AgentMonitor - Simple Startup Script
# API keys are loaded from backend/.env file (DO NOT hardcode keys here)

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $projectRoot "backend"
$frontendDir = Join-Path $projectRoot "frontend"
$envFile = Join-Path $backendDir ".env"

# Load .env file if it exists
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
    Write-Host "✅ Loaded environment variables from .env" -ForegroundColor Green
} else {
    Write-Host "⚠️  WARNING: .env file not found at $envFile" -ForegroundColor Yellow
    Write-Host "   Please create it with your API keys" -ForegroundColor Yellow
}

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

