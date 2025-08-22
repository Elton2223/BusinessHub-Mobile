# Simple .env file creator for BusinessHub Mobile
Write-Host "🔧 Creating minimal .env file..." -ForegroundColor Green

$envContent = @"
# Essential API Configuration
API_BASE_URL=http://10.0.2.2:3005
API_VERSION=v1

# App Configuration
APP_NAME=BusinessHub Mobile
ENVIRONMENT=development
DEBUG_MODE=true

# Feature Flags
ENABLE_SOCIAL_LOGIN=true
ENABLE_PUSH_NOTIFICATIONS=true
ENABLE_ANALYTICS=true

# Add your actual API keys and secrets below when needed
# GOOGLE_CLIENT_ID=your-google-client-id
# GOOGLE_CLIENT_SECRET=your-google-client-secret
# JWT_SECRET=your-jwt-secret
# DATABASE_URL=your-database-url
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8

Write-Host "✅ Created minimal .env file!" -ForegroundColor Green
Write-Host "📝 API Base URL: http://10.0.2.2:3005" -ForegroundColor Cyan
Write-Host "💡 Edit .env file to add your actual API keys when needed" -ForegroundColor Yellow
