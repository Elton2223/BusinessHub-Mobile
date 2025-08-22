# BusinessHub Mobile Environment Setup Script
# This script helps you set up your environment configuration

Write-Host "🚀 BusinessHub Mobile Environment Setup" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if .env file exists
if (Test-Path ".env") {
    Write-Host "⚠️  .env file already exists!" -ForegroundColor Yellow
    $overwrite = Read-Host "Do you want to overwrite it? (y/N)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "Setup cancelled." -ForegroundColor Red
        exit
    }
}

# Copy env.example to .env
if (Test-Path "env.example") {
    Copy-Item "env.example" ".env"
    Write-Host "✅ Created .env file from env.example" -ForegroundColor Green
} else {
    Write-Host "❌ env.example file not found!" -ForegroundColor Red
    exit
}

# Get user's preferred API URL
Write-Host ""
Write-Host "🌐 API Base URL Configuration" -ForegroundColor Cyan
Write-Host "Choose your preferred API base URL:" -ForegroundColor White
Write-Host "1. http://10.0.2.2:3005 (Default - works with Android emulator)" -ForegroundColor Gray
Write-Host "2. http://127.0.0.1:3005 (Localhost - works with iOS simulator)" -ForegroundColor Gray
Write-Host "3. Custom IP address" -ForegroundColor Gray
Write-Host "4. Keep default (10.0.2.2:3005)" -ForegroundColor Gray

$choice = Read-Host "Enter your choice (1-4)"

$apiUrl = switch ($choice) {
    "1" { "http://10.0.2.2:3005" }
    "2" { "http://127.0.0.1:3005" }
    "3" { 
        $customIp = Read-Host "Enter your custom IP address (e.g., 192.168.1.100)"
        "http://$customIp`:3005"
    }
    default { "http://10.0.2.2:3005" }
}

# Update the .env file with the chosen API URL
$envContent = Get-Content ".env"
$envContent = $envContent -replace "API_BASE_URL=.*", "API_BASE_URL=$apiUrl"
$envContent | Set-Content ".env"

Write-Host ""
Write-Host "✅ Environment setup completed!" -ForegroundColor Green
Write-Host "📝 API Base URL set to: $apiUrl" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔧 Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit .env file to add your actual API keys and secrets" -ForegroundColor White
Write-Host "2. Make sure your LoopBack4 server is running on port 3005" -ForegroundColor White
Write-Host "3. Run 'flutter run' to start your app" -ForegroundColor White
Write-Host ""
Write-Host "💡 Tip: The API URL will work automatically across all devices!" -ForegroundColor Green
