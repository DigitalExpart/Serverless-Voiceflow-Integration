# Quick deployment script for No-Limits API
# Run this to deploy your unlimited API to Vercel

Write-Host "`n🚀 Deploying No-Limits API to Vercel`n" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan

# Step 1: Verify we're in the right directory
Write-Host "`n📁 Step 1: Checking directory..." -ForegroundColor Yellow
$currentDir = Get-Location
Write-Host "   Current directory: $currentDir" -ForegroundColor Gray

if (!(Test-Path "api/voiceflow/search.js")) {
    Write-Host "   ❌ Error: api/voiceflow/search.js not found!" -ForegroundColor Red
    Write-Host "   Please run this script from your project root directory." -ForegroundColor Yellow
    exit 1
}
Write-Host "   ✅ Project files found" -ForegroundColor Green

# Step 2: Check Vercel CLI is installed
Write-Host "`n🔧 Step 2: Checking Vercel CLI..." -ForegroundColor Yellow
try {
    $vercelVersion = vercel --version 2>&1
    Write-Host "   ✅ Vercel CLI installed: $vercelVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Vercel CLI not found!" -ForegroundColor Red
    Write-Host "`n   Install Vercel CLI:" -ForegroundColor Yellow
    Write-Host "   npm install -g vercel" -ForegroundColor White
    Write-Host "   or" -ForegroundColor Gray
    Write-Host "   pnpm install -g vercel`n" -ForegroundColor White
    exit 1
}

# Step 3: Show what's being deployed
Write-Host "`n📦 Step 3: What's included in this deployment:" -ForegroundColor Yellow
Write-Host "   ✅ NO product limits - returns ALL results" -ForegroundColor Green
Write-Host "   ✅ NO brand limits - shows ALL brands" -ForegroundColor Green
Write-Host "   ✅ NO category limits - shows ALL categories" -ForegroundColor Green
Write-Host "   ✅ NO filter limits - shows ALL options" -ForegroundColor Green
Write-Host "   ✅ Product management endpoints (add/update/delete)" -ForegroundColor Green

# Step 4: Confirm deployment
Write-Host "`n⚠️  Step 4: Ready to deploy" -ForegroundColor Yellow
Write-Host "   This will deploy to PRODUCTION" -ForegroundColor White
$confirm = Read-Host "`n   Continue? (y/n)"

if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "`n   ❌ Deployment cancelled" -ForegroundColor Red
    exit 0
}

# Step 5: Deploy
Write-Host "`n🚀 Step 5: Deploying to Vercel..." -ForegroundColor Yellow
Write-Host "   This may take 30-60 seconds...`n" -ForegroundColor Gray

$deployStartTime = Get-Date

try {
    vercel --prod
    
    $deployEndTime = Get-Date
    $deployDuration = ($deployEndTime - $deployStartTime).TotalSeconds
    
    Write-Host "`n   ✅ Deployment completed in $([math]::Round($deployDuration, 1)) seconds!" -ForegroundColor Green
    
} catch {
    Write-Host "`n   ❌ Deployment failed!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "`n   Try:" -ForegroundColor Yellow
    Write-Host "   1. Make sure you're logged in: vercel login" -ForegroundColor White
    Write-Host "   2. Link project: vercel link" -ForegroundColor White
    Write-Host "   3. Try again: vercel --prod`n" -ForegroundColor White
    exit 1
}

# Step 6: Next steps
Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🎉 DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "📋 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Test your deployment:" -ForegroundColor White
Write-Host "      .\test-no-limits.ps1`n" -ForegroundColor Cyan

Write-Host "   2. Your API endpoints are now live:" -ForegroundColor White
Write-Host "      GET  /api/voiceflow/search (health check)" -ForegroundColor Gray
Write-Host "      POST /api/voiceflow/search (search products)" -ForegroundColor Gray
Write-Host "      POST /api/voiceflow/smart-search (smart search)" -ForegroundColor Gray
Write-Host "      POST /api/voiceflow/add-product (add product)" -ForegroundColor Gray
Write-Host "      POST /api/voiceflow/add-products (bulk add)" -ForegroundColor Gray
Write-Host "      PUT  /api/voiceflow/update-product (update)" -ForegroundColor Gray
Write-Host "      DELETE /api/voiceflow/delete-product (delete)`n" -ForegroundColor Gray

Write-Host "   3. Update Voiceflow with your production URL" -ForegroundColor White
Write-Host "      (shown above in vercel output)`n" -ForegroundColor Gray

Write-Host "✅ Your API now returns ALL products with NO limits!" -ForegroundColor Green
Write-Host "   • 'tube' query → ALL 15,000+ products" -ForegroundColor White
Write-Host "   • Filter options → ALL brands & categories" -ForegroundColor White
Write-Host "   • No artificial caps or truncation`n" -ForegroundColor White

Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan




